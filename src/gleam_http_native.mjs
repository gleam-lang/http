import { Ok, Error } from "./gleam.mjs";
import {
  Get,
  Post,
  Head,
  Put,
  Delete,
  Trace,
  Connect,
  Options,
  Patch,
  Other,
} from "./gleam/http.mjs";

/**
  @param {number} ch
*/
export function is_valid_tchar(ch) {
  try {
    switch (ch) {
      case  '33': return true;
      case  '35': return true;
      case  '36': return true;
      case  '37': return true;
      case  '38': return true;
      case  '39': return true;
      case  '42': return true;
      case  '43': return true;
      case  '45': return true;
      case  '46': return true;
      case  '94': return true;
      case  '95': return true;
      case  '96': return true;
      case '124': return true;
      case '126': return true;
    }
    // DIGIT
    if (ch >= 0x30 && ch <= 0x39) return true;
    // ALPHA
    if (ch >= 0x41 && ch <= 0x5A || ch >= 0x61 && ch <= 0x7A) return true;
  } catch {}
  return false;
}

export function decode_method(value) {
  try {
    switch (value) {
      case "GET":
        return new Ok(new Get());
      case "POST":
        return new Ok(new Post());
      case "HEAD":
        return new Ok(new Head());
      case "PUT":
        return new Ok(new Put());
      case "DELETE":
        return new Ok(new Delete());
      case "TRACE":
        return new Ok(new Trace());
      case "CONNECT":
        return new Ok(new Connect());
      case "OPTIONS":
        return new Ok(new Options());
      case "PATCH":
        return new Ok(new Patch());
    }
    if (typeof value === 'string') {
      for (const v of value)
        if (!is_valid_tchar(v)) return new Error(undefined);
      return new Ok(new Other(value));
    }
  } catch {}
  return new Error(undefined);
}
