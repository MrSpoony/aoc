import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input01.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.fold(#([], []), fn(acc, line) {
    let assert Ok(#(x, y)) = line |> string.split_once("   ")
    let assert Ok(left) = x |> int.parse
    let assert Ok(right) = y |> int.parse
    #([left, ..{ acc.0 }], [right, ..{ acc.1 }])
  })
}

pub fn part1(input: String) {
  let #(left, right) = parse(input)
  let left_sorted = left |> list.sort(by: int.compare)
  let right_sorted = right |> list.sort(by: int.compare)
  list.zip(left_sorted, right_sorted)
  |> list.fold(0, fn(acc, pair) {
    acc + int.absolute_value({ pair.0 - pair.1 })
  })
}

pub fn part2(input: String) {
  let #(left, right) = parse(input)
  let map =
    right
    |> list.fold(dict.new(), fn(acc, x) {
      acc
      |> dict.upsert(x, fn(v) {
        case v {
          None -> 1
          Some(v) -> v + 1
        }
      })
    })
  left
  |> list.map(fn(x) { x * result.unwrap(dict.get(map, x), 0) })
  |> list.fold(0, fn(acc, x) { acc + x })
}
