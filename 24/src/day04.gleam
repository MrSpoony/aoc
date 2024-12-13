import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input04.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) { string.to_graphemes(x) })
}

fn solve_line_p1(input: List(String)) {
  case input {
    [] -> 0
    ["X", "M", "A", "S", ..rest] -> 1 + solve_line_p1(["S", ..rest])
    ["S", "A", "M", "X", ..rest] -> 1 + solve_line_p1(["X", ..rest])
    [_, ..rest] -> solve_line_p1(rest)
  }
}

pub fn create_diagonals(matrix: List(List(a)), len: Int) {
  case matrix {
    [] -> []
    [[], ..rest] -> create_diagonals(rest, len)
    rest -> {
      let x = rest |> list.take(len) |> list.flat_map(list.take(_, 1))
      let rest =
        rest
        |> list.take(len)
        |> list.map(list.drop(_, 1))
        |> list.append(list.drop(rest, len))
      [x, ..create_diagonals(rest, len + 1)]
    }
  }
}

fn zip3(x: List(a), y: List(b), z: List(c)) {
  case x, y, z {
    [x, ..xs], [y, ..ys], [z, ..zs] -> [#(x, y, z), ..zip3(xs, ys, zs)]
    _, _, _ -> []
  }
}

fn check3(x: List(String), y: List(String), z: List(String)) {
  case x, y, z {
    [a, _, b, ..], [_, "A", _, ..], [c, _, d, ..]
      if { a == "M" && d == "S" || a == "S" && d == "M" }
      && { b == "M" && c == "S" || b == "S" && c == "M" }
    -> 1 + check3(list.drop(x, 1), list.drop(y, 1), list.drop(z, 1))
    [_, ..rest1], [_, ..rest2], [_, ..rest3] -> check3(rest1, rest2, rest3)
    _, _, _ -> 0
  }
}

fn solve_grid_p2(input: List(List(String))) {
  case input {
    [prev, cur, next, ..] -> {
      check3(prev, cur, next) + solve_grid_p2(list.drop(input, 1))
    }
    _ -> 0
  }
}

pub fn part1(input: String) {
  let input = parse(input)

  let solve_grid = fn(x) {
    list.fold(x, 0, fn(acc, line) { acc + solve_line_p1(line) })
  }

  [
    input,
    input |> list.transpose,
    input |> create_diagonals(1),
    input |> list.reverse |> create_diagonals(1),
  ]
  |> list.fold(0, fn(acc, grid) { acc + solve_grid(grid) })
}

pub fn part2(input: String) {
  input |> parse |> solve_grid_p2
}
