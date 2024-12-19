import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input19.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  let assert Ok(#(towels, designs)) =
    input |> string.trim |> string.split_once("\n\n")

  #(towels |> string.split(", "), designs |> string.split("\n"))
}

fn is_possible(towels: List(String), design: String, memo: Dict(String, Int)) {
  use <- bool.guard(design |> string.length == 0, #(memo, 1))
  use <- bool.guard(memo |> dict.get(design) |> result.is_ok, #(
    memo,
    memo |> dict.get(design) |> result.unwrap(-1),
  ))
  let #(memo, count) =
    towels
    |> list.filter(string.starts_with(design, _))
    |> list.fold(#(memo, 0), fn(acc, towl) {
      let #(memo, n) =
        is_possible(
          towels,
          string.slice(design, towl |> string.length, design |> string.length),
          acc.0,
        )
      #(memo, acc.1 + n)
    })
  #(memo |> dict.insert(design, count), count)
}

pub fn part1(input: String) {
  let #(towels, designs) = parse(input)
  designs
  |> list.filter(fn(d) { is_possible(towels, d, dict.new()) |> pair.second > 0 })
  |> list.length
}

pub fn part2(input: String) {
  let #(towels, designs) = parse(input)
  designs
  |> list.map(fn(d) { is_possible(towels, d, dict.new()) |> pair.second })
  |> int.sum
}
