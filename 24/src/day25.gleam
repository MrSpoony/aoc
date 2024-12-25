import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input25.txt")
  part1(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  let mp =
    input
    |> string.trim
    |> string.split("\n\n")
    |> list.map(fn(key) {
      key
      |> string.split("\n")
      |> list.map(string.to_graphemes)
      |> list.transpose
      |> list.fold(#([], ""), fn(acc, row) {
        let inner =
          row
          |> list.fold(
            #(-1, row |> list.first |> result.unwrap("a")),
            fn(acc, x) {
              case x == acc.1 {
                True -> #(acc.0 + 1, acc.1)
                False -> #(acc.0, acc.1)
              }
            },
          )
        #([inner.0, ..acc.0], inner.1)
      })
    })
    |> list.group(fn(l) { l.1 })
  #(
    mp |> dict.get(".") |> result.unwrap([#([], ".")]) |> list.map(pair.first),
    mp |> dict.get("#") |> result.unwrap([#([], "#")]) |> list.map(pair.first),
  )
}

fn matches(lock: List(Int), key: List(Int)) {
  case lock, key {
    [], [] -> True
    [l, ..ls], [k, ..ks] ->
      case l <= k {
        True -> matches(ls, ks)
        False -> False
      }
    _, _ -> False
  }
}

pub fn part1(input: String) {
  let #(keys, locks) = parse(input)
  locks
  |> list.fold(0, fn(acc, lock) {
    keys
    |> list.fold(acc, fn(acc, key) {
      case matches(lock, key) {
        True -> acc + 1
        False -> acc
      }
    })
  })
}
