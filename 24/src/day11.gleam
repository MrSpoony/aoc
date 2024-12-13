import gleam/bool
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/actor
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input11.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  input |> string.trim |> string.split(" ") |> list.filter_map(int.parse)
}

fn blink(cur: Int) -> List(Int) {
  let assert Ok(digits) = int.digits(cur, 10)
  let n = list.length(digits)

  case cur, n % 2 {
    0, _ -> [1]
    _, 1 -> [cur * 2024]
    _, _ -> {
      let #(a, b) = list.split(digits, n / 2)
      let assert Ok(a) = int.undigits(a, 10)
      let assert Ok(b) = int.undigits(b, 10)
      [a, b]
    }
  }
}

fn dp(cache: Subject(Message), cur: Int, iterations: Int) {
  use <- bool.guard(iterations == 0, 1)
  case process.call(cache, Get(_, cur, iterations), 100) {
    Ok(res) -> res
    Error(Nil) -> {
      let res =
        cur
        |> blink
        |> list.map(dp(cache, _, iterations - 1))
        |> int.sum
      process.send(cache, Put(cur, iterations, res))
      res
    }
  }
}

fn solve_p1(line: List(Int), iterations: Int) {
  case iterations {
    0 -> line
    _ -> line |> list.flat_map(blink) |> solve_p1(iterations - 1)
  }
}

pub type Message {
  Shutdown
  Put(cur: Int, iterations: Int, length: Int)
  Get(response: Subject(Result(Int, Nil)), cur: Int, iterations: Int)
}

fn handle_message(message: Message, cache: Dict(#(Int, Int), Int)) {
  case message {
    Shutdown -> actor.Stop(process.Normal)
    Put(cur, iterations, length) -> {
      let new_cache = dict.insert(cache, #(cur, iterations), length)
      actor.continue(new_cache)
    }
    Get(client, cur, iterations) -> {
      process.send(client, dict.get(cache, #(cur, iterations)))
      actor.continue(cache)
    }
  }
}

pub fn part1(input: String) {
  let line = parse(input)
  solve_p1(line, 25)
  |> list.length
}

pub fn part2(input: String) {
  let line = parse(input)
  // Need to have "global" state to not copy the dict every time
  let assert Ok(cache) = actor.start(dict.new(), handle_message)
  line |> list.map(dp(cache, _, 75)) |> int.sum
}
