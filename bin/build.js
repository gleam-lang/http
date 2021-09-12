// Gleam build.js version:2021-09-12.b

import {
  rm,
  stat,
  copyFile,
  readFile,
  mkdir,
  access,
  readdir,
} from "fs/promises";
import { resolve, relative, join } from "path";
import { promisify } from "util";
import { exec as callbackExec } from "child_process";

let exec = promisify(callbackExec);

export async function build() {
  let { name, gleamDependencies } = JSON.parse(
    await readFile("./package.json")
  );

  await Promise.all(gleamDependencies.map(clone));
  for (let dep of gleamDependencies) await cachedBuildProject(dep);

  await buildProject({
    name,
    root: ".",
    includeTests: true,
    dependencies: gleamDependencies.map((d) => d.name),
  });

  return {
    name,
  };
}

async function copyJs(name, dir) {
  let inDir = join(dir, "src");
  let out = outDir(name);
  let files = await readdir(inDir);
  files.map(async (file) => {
    if (file.endsWith(".js")) {
      await copyFile(join(inDir, file), join(out, file));
    }
  });
}

async function cachedBuildProject(info) {
  if (await fileExists(outDir(info.name))) return;
  await buildProject(info);
}

async function buildProject({ name, root, dependencies, includeTests }) {
  console.log(`Building ${name}`);
  let dir = root || libraryDir(name);
  let src = join(dir, "src");
  let test = join(dir, "test");
  let out = outDir(name);
  await rm(out, { recursive: true, force: true });
  try {
    await exec(
      [
        "gleam compile-package",
        `--name ${name}`,
        "--target javascript",
        `--src ${src}`,
        includeTests ? `--test ${test}` : "",
        `--out ${out}`,
        (dependencies || []).map((dep) => `--lib=${outDir(dep)}`).join(" "),
      ].join(" ")
    );
  } catch (error) {
    console.error(error.stderr);
    process.exit(1);
  }
  await copyJs(name, dir);
}

async function clone({ name, ref, url }) {
  let dir = libraryDir(name);
  if (await fileExists(dir)) return;
  console.log("Cloning", name);
  await mkdir(dir, { recursive: true });
  await exec(`git clone --depth=1 --branch="${ref}" "${url}" "${dir}"`);
}

function libraryDir(name) {
  return resolve(join("target", "deps", name));
}

function outDir(name) {
  return resolve(join("target", "lib", name));
}

async function fileExists(path) {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}

async function test() {
  let gleamPackage = await build();
  try {
    await import("../test/polyfills.js");
  } catch {}

  console.log("Running tests...");

  let dir = `target/lib/${gleamPackage.name}`;
  let passes = 0;
  let failures = 0;

  for await (let path of await getFiles(dir)) {
    if (!path.endsWith("_test.js")) continue;
    let module = await import(path);

    for await (let fnName of Object.keys(module)) {
      if (!fnName.endsWith("_test")) continue;
      let error = await runTest(module[fnName]);
      if (error) {
        let moduleName = "\n" + relative(dir, path).slice(0, -3);
        process.stdout.write(`\n❌ ${moduleName}.${fnName}: ${error}\n`);
        failures++;
      } else {
        process.stdout.write(`\u001b[32m.\u001b[0m`);
        passes++;
      }
    }
  }

  console.log(`

${passes + failures} tests
${failures} failures`);
  process.exit(failures ? 1 : 0);
}

async function runTest(test) {
  let output;
  try {
    output = await test();
  } catch (error) {
    return `//js(Error("${error.message}"))`;
  }
  // if (
  //   typeof output === "Object" &&
  //   output.__gleam_prelude_variant__ === "Error"
  // ) {
  //   return output.inspect();
  // }
}

async function start() {
  let { name } = await build();
  let { main } = await import(join(outDir(name), "index.js"));
  return main();
}

async function getFiles(dir) {
  const subdirs = await readdir(dir);
  const files = await Promise.all(
    subdirs.map(async (subdir) => {
      const res = resolve(dir, subdir);
      return (await stat(res)).isDirectory() ? getFiles(res) : res;
    })
  );
  return files.reduce((a, f) => a.concat(f), []);
}

async function main() {
  switch (process.argv[process.argv.length - 1]) {
    case "build":
      return await build();

    case "test":
      return await test();

    case "start":
      return await start();

    default:
      console.error(`
Usage: 
  node bin/build.js test
  node bin/build.js build
  node bin/build.js start
`);
      process.exit(1);
  }
}

main();
