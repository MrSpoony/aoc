import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input13.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Pos {
  Pos(x: Int, y: Int)
}

fn mul(p: Pos, n: Int) {
  Pos(p.x * n, p.y * n)
}

fn add(p1: Pos, p2: Pos) {
  Pos(p1.x + p2.x, p1.y + p2.y)
}

fn parse(input: String) {
  use machine <- list.map(input |> string.trim |> string.split("\n\n"))
  let assert Ok(#(button_a, rest)) = string.split_once(machine, "\n")
  let assert Ok(#(button_b, prize)) = string.split_once(rest, "\n")
  let parse_pos = fn(line, prefix, infix) {
    let line = string.drop_start(line, string.length(prefix))
    let assert Ok(#(x, y)) = string.split_once(line, infix)
    let assert Ok(x) = x |> int.parse
    let assert Ok(y) = y |> int.parse
    Pos(x, y)
  }
  #(
    button_a |> parse_pos("Button A: X+", ", Y+"),
    button_b |> parse_pos("Button B: X+", ", Y+"),
    prize |> parse_pos("Prize: X=", ", Y="),
  )
}

fn cost(machine) {
  let #(button_a, button_b, prize) = machine
  // using hint in problem statement
  list.range(0, 100)
  |> list.fold(Error(Nil), fn(acc, i) {
    list.range(0, 100)
    |> list.fold(acc, fn(acc, j) {
      use <- bool.guard(
        { button_a |> mul(i) |> add(button_b |> mul(j)) } != prize,
        acc,
      )
      case acc {
        Ok(n) -> Ok(int.min(n, 3 * i + j))
        Error(Nil) -> Ok(3 * i + j)
      }
    })
  })
  |> result.unwrap(0)
}

pub fn part1(input: String) {
  input
  |> parse
  |> list.fold(0, fn(acc, machine) { acc + cost(machine) })
}

pub fn part2(input: String) {
  input
  |> parse
  |> list.map(fn(m) {
    #(
      m.0,
      m.1,
      m.2
        |> add(Pos(x: 10_000_000_000_000, y: 10_000_000_000_000)),
    )
  })
  |> list.fold(0, fn(acc, machine) {
    let #(button_a, button_b, prize) = machine
    let numerator = button_a.y * prize.x - prize.y * button_a.x
    let denominator = button_a.y * button_b.x - button_b.y * button_a.x
    use <- bool.guard(numerator % denominator != 0, acc)
    let m = numerator / denominator
    let numerator = prize.x - button_b.x * m
    let denominator = button_a.x
    use <- bool.guard(numerator % denominator != 0, acc)
    let n = numerator / denominator
    acc + 3 * n + m
  })
}
// | b1x*N + b2x*M = px |
// | b1y*N + b2y*M = py | 
// N = (px - b2x*M)/b1x
// b1y*(px - b2x*M)/b1x + b2y*M = py // simplify
// b1y*px/b1x - b1y*b2x*M/b1x + b2y*M = py // multiply b1x
// b1y*px - b1y*b2x*M + b2y*M*b1x = py*b1x // factor M
// b1y*px - M*(b1y*b2x - b2y*b1x) = py*b1x // neg b1y*px
// - M*(b1y*b2x - b2y*b1x) = py*b1x - b1y*px // mul -1
// M*(b1y*b2x - b2y*b1x) = b1y*px - py*b1x // divide by  (b1y*b2x + b2y*b1x)
// M = (b1y*px - py*b1x) / (b1y*b2x - b2y*b1x)
