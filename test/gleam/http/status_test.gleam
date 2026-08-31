import gleam/http/status

pub fn class_test() {
  let assert Ok(status.Success) = status.to_class(status.ok)
  let assert Ok(status.ServerError) = status.to_class(555)
  let assert Error(_) = status.to_class(1337)
}

pub fn string_test() {
  assert "OK" == status.to_string(status.ok)
  assert "OK" == status.to_string(200)
  assert "[unknown HTTP code: 99]" == status.to_string(99)
}
