import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input14.txt")
  part1(input, #(101, 103)) |> int.to_string |> io.println
  part2(input, #(101, 103)) |> int.to_string |> io.println
}

type Pos {
  Pos(x: Int, y: Int)
}

fn add(p1: Pos, p2: Pos) {
  Pos(p1.x + p2.x, p1.y + p2.y)
}

fn mod(p1: Pos, dim: #(Int, Int)) {
  let #(width, height) = dim
  Pos({ p1.x + width } % width, { p1.y + height } % height)
}

type Robot {
  Robot(pos: Pos, vel: Pos)
}

fn simulate(robot: Robot, steps: Int, dimensions: #(Int, Int)) {
  case steps {
    0 -> robot
    _ ->
      robot.pos
      |> add(robot.vel)
      |> mod(dimensions)
      |> Robot(robot.vel)
      |> simulate(steps - 1, dimensions)
  }
}

fn parse(input: String) {
  use line <- list.map(input |> string.trim |> string.split("\n"))
  let line = line |> string.drop_start(2)
  let parse_pos = fn(ints) {
    let assert Ok(#(x, y)) = ints |> string.split_once(",")
    let assert Ok(x) = x |> int.parse
    let assert Ok(y) = y |> int.parse
    Pos(x, y)
  }
  let assert Ok(#(pos, vel)) = line |> string.split_once(" v=")
  let p = pos |> parse_pos
  let v = vel |> parse_pos
  Robot(p, v)
}

pub fn part1(input: String, dimensions: #(Int, Int)) {
  let #(width, height) = dimensions
  input
  |> parse
  |> list.map(fn(robot) { simulate(robot, 100, dimensions) })
  |> list.fold(dict.new(), fn(acc, robot) {
    dict.upsert(acc, robot.pos, fn(x) {
      case x {
        Some(entry) -> entry + 1
        None -> 1
      }
    })
  })
  |> dict.filter(fn(pos, _) {
    !{ { width - 1 } / 2 == pos.x || { height - 1 } / 2 == pos.y }
  })
  |> dict.to_list
  |> list.group(fn(entry) {
    let #(pos, _) = entry
    case pos.x < { width - 1 } / 2, pos.y < { height - 1 } / 2 {
      True, True -> 1
      True, False -> 2
      False, True -> 3
      False, False -> 4
    }
  })
  |> dict.fold(1, fn(acc, _, vals) {
    acc * list.fold(vals, 0, fn(acc, val) { acc + val.1 })
  })
}

pub fn part2(input: String, dimensions: #(Int, Int)) {
  let #(width, height) = dimensions
  let robots = parse(input)
  let assert Ok(#(steps, robots)) =
    list.range(1, 1_000_000)
    |> list.fold(Error(robots), fn(robots, steps) {
      use <- bool.guard(robots |> result.is_ok, robots)
      let robots = robots |> result.unwrap_error([])
      let robots =
        robots
        |> list.map(simulate(_, 1, dimensions))
      let variance = fn(nums) {
        let mean =
          int.to_float(nums |> int.sum) /. int.to_float(nums |> list.length)
        {
          nums
          |> list.map(fn(x) {
            let x = int.to_float(x)
            { x -. mean } *. { x -. mean }
          })
          |> float.sum
        }
        /. int.to_float(list.length(nums))
      }
      let var_x = robots |> list.map(fn(p) { p.pos.x }) |> variance
      let var_y = robots |> list.map(fn(p) { p.pos.y }) |> variance
      case var_x <. 600.0 && var_y <. 600.0 {
        True -> Ok(#(steps, robots))
        False -> Error(robots)
      }
    })
  let positions =
    robots
    |> list.fold(dict.new(), fn(acc, robot) { dict.insert(acc, robot.pos, 1) })
  list.range(0, width - 1)
  |> list.map(fn(line) {
    list.range(0, height - 1)
    |> list.map(fn(cell) {
      case dict.get(positions, Pos(line, cell)) {
        Ok(_) -> "#"
        Error(Nil) -> " "
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
  steps
}
