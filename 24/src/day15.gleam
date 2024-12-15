import envoy
import gleam/dict.{type Dict}
import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result.{try}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input15.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Pos {
  Pos(x: Int, y: Int)
}

type Dir {
  Up
  Down
  Left
  Right
}

fn to_string(d: Dir) {
  case d {
    Up -> "^"
    Down -> "v"
    Left -> "<"
    Right -> ">"
  }
}

fn move(pos: Pos, dir: Dir) {
  case dir {
    Up -> Pos(pos.x - 1, pos.y)
    Down -> Pos(pos.x + 1, pos.y)
    Left -> Pos(pos.x, pos.y - 1)
    Right -> Pos(pos.x, pos.y + 1)
  }
}

fn parse_moves(moves: String) {
  let assert Ok(moves) =
    moves
    |> string.split("\n")
    |> string.join("")
    |> string.to_graphemes()
    |> list.map(fn(x) {
      case x {
        "^" -> Ok(Up)
        "v" -> Ok(Down)
        "<" -> Ok(Left)
        ">" -> Ok(Right)
        _ -> Error(Nil)
      }
    })
    |> result.all
  moves
}

fn parse_p1(input: String) {
  let assert Ok(#(grid, moves)) =
    input |> string.trim |> string.split_once("\n\n")
  let #(grid, start) =
    grid
    |> string.split("\n")
    |> list.index_fold(#(dict.new(), Pos(0, 0)), fn(acc, line, i) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc, char, j) {
        let newdict = dict.insert(acc.0, Pos(i, j), char)
        case char {
          "@" -> #(newdict, Pos(i, j))
          _ -> #(newdict, acc.1)
        }
      })
    })
  let moves = parse_moves(moves)
  #(grid, start, moves)
}

fn parse_p2(input: String) {
  let assert Ok(#(grid, moves)) =
    input |> string.trim |> string.split_once("\n\n")
  let #(grid, start) =
    grid
    |> string.split("\n")
    |> list.index_fold(#(dict.new(), Pos(0, 0)), fn(acc, line, i) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc, char, j) {
        let #(grid, start) = acc
        case char {
          "#" -> {
            #(
              grid
                |> dict.insert(Pos(i, 2 * j), "#")
                |> dict.insert(Pos(i, 2 * j + 1), "#"),
              start,
            )
          }
          "O" -> {
            #(
              grid
                |> dict.insert(Pos(i, 2 * j), "[")
                |> dict.insert(Pos(i, 2 * j + 1), "]"),
              start,
            )
          }
          "." -> {
            #(
              grid
                |> dict.insert(Pos(i, 2 * j), ".")
                |> dict.insert(Pos(i, 2 * j + 1), "."),
              start,
            )
          }
          "@" -> {
            #(
              grid
                |> dict.insert(Pos(i, 2 * j), "@")
                |> dict.insert(Pos(i, 2 * j + 1), "."),
              Pos(i, 2 * j),
            )
          }
          _ -> #(grid, start)
        }
      })
    })
  let moves = parse_moves(moves)
  #(grid, start, moves)
}

fn move_boxes_p1(grid: Dict(Pos, String), cur: Pos, dir: Dir) {
  let next_pos = cur |> move(dir)
  case grid |> dict.get(next_pos) {
    Ok("#") -> Error(Nil)
    Ok("O") -> {
      case move_boxes_p1(grid, next_pos, dir) {
        Ok(grid) ->
          Ok(
            grid
            |> dict.insert(cur, ".")
            |> dict.insert(next_pos, "O"),
          )
        Error(Nil) -> Error(Nil)
      }
    }
    Ok(".") -> {
      Ok(
        grid
        |> dict.insert(cur, ".")
        |> dict.insert(next_pos, "O"),
      )
    }
    _ -> Error(Nil)
  }
}

// always call on the left box
fn move_boxes_p2(grid: Dict(Pos, String), cur: Pos, dir: Dir) {
  let cur2 = cur |> move(Right)
  let update = fn(grid) {
    grid
    |> dict.insert(cur, ".")
    |> dict.insert(cur2, ".")
    |> dict.insert(cur |> move(dir), "[")
    |> dict.insert(cur2 |> move(dir), "]")
  }
  case dir {
    Up | Down -> {
      let #(next_pos1, next_pos2) = #(cur |> move(dir), cur2 |> move(dir))
      case grid |> dict.get(next_pos1), grid |> dict.get(next_pos2) {
        Ok("#"), _ -> Error(Nil)
        _, Ok("#") -> Error(Nil)
        Ok("."), Ok(".") -> Ok(grid |> update)
        Ok("."), Ok("[") ->
          move_boxes_p2(grid, next_pos2, dir)
          |> result.map(update)
        Ok("]"), Ok(".") ->
          move_boxes_p2(grid, next_pos1 |> move(Left), dir)
          |> result.map(update)
        Ok("]"), Ok("[") -> {
          use grid <- try(move_boxes_p2(grid, next_pos1 |> move(Left), dir))
          use grid <- try(move_boxes_p2(grid, next_pos2, dir))
          Ok(grid |> update)
        }
        Ok("["), Ok("]") ->
          move_boxes_p2(grid, next_pos1, dir) |> result.map(update)
        _, _ -> Error(Nil)
      }
    }
    Left | Right -> {
      let next_pos = case dir {
        Left -> cur |> move(Left)
        Right -> cur |> move(Right) |> move(Right)
        // shouldn't happen
        _ -> cur
      }
      let handle_box = fn(is_left) {
        let box_pos = case is_left {
          True -> next_pos
          False -> next_pos |> move(Left)
        }
        move_boxes_p2(grid, box_pos, dir) |> result.map(update)
      }
      case grid |> dict.get(next_pos) {
        Ok("#") -> Error(Nil)
        Ok(".") -> Ok(grid |> update)
        Ok("[") as x | Ok("]") as x -> handle_box(x == Ok("["))
        _ -> Error(Nil)
      }
    }
  }
}

fn simulate_p1(grid: Dict(Pos, String), cur: Pos, dir: Dir) {
  let next_pos = cur |> move(dir)
  case grid |> dict.get(next_pos) {
    Ok("#") -> #(grid, cur)
    Ok("O") -> {
      case move_boxes_p1(grid, next_pos, dir) {
        Ok(grid) -> #(
          grid
            |> dict.insert(cur, ".")
            |> dict.insert(next_pos, "@"),
          next_pos,
        )
        Error(Nil) -> #(grid, cur)
      }
    }
    Ok(".") -> {
      #(
        grid
          |> dict.insert(cur, ".")
          |> dict.insert(next_pos, "@"),
        next_pos,
      )
    }
    _ -> #(grid, cur)
  }
}

fn simulate_p2(grid: Dict(Pos, String), cur: Pos, dir: Dir) {
  let next_pos = cur |> move(dir)
  let handle_box = fn(is_left) {
    let box_pos = case is_left {
      True -> next_pos
      False -> next_pos |> move(Left)
    }
    case move_boxes_p2(grid, box_pos, dir) {
      Ok(grid) -> {
        #(
          grid
            |> dict.insert(cur, ".")
            |> dict.insert(next_pos, "@"),
          next_pos,
        )
      }
      Error(Nil) -> #(grid, cur)
    }
  }
  case grid |> dict.get(next_pos) {
    Ok("#") -> #(grid, cur)
    Ok("[") as x | Ok("]") as x -> handle_box(x == Ok("["))
    Ok(".") -> {
      let grid =
        grid
        |> dict.insert(cur, ".")
        |> dict.insert(next_pos, "@")
      #(grid, next_pos)
    }
    _ -> #(grid, cur)
  }
}

pub fn part1(input: String) {
  let #(grid, start, moves) = parse_p1(input)
  moves
  |> list.fold(#(grid, start), fn(acc, dir) {
    let #(grid, pos) = acc
    simulate_p1(grid, pos, dir)
  })
  |> pair.first
  |> dict.to_list
  |> list.filter_map(fn(x) {
    let #(pos, char) = x
    case char {
      "O" -> Ok(100 * pos.x + pos.y)
      _ -> Error(Nil)
    }
  })
  |> int.sum
}

fn show(pos, grid) {
  list.range(0, 10)
  |> list.map(fn(i) {
    list.range(0, 40)
    |> list.map(fn(j) {
      case grid |> dict.get(Pos(i, j)) {
        Ok(x) -> x
        Error(Nil) -> ""
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
  io.println(pos |> to_string)
}

pub fn part2(input: String) {
  let #(grid, start, moves) = parse_p2(input)
  moves
  |> list.fold(#(grid, start), fn(acc, dir) {
    let #(grid, pos) = acc
    let #(grid, start) = simulate_p2(grid, pos, dir)
    case envoy.get("AOC_DEBUG") {
      Ok(_) -> {
        show(dir, grid)
        let assert Ok(_) = erlang.get_line("")
        Nil
      }
      Error(_) -> Nil
    }
    #(grid, start)
  })
  |> pair.first
  |> dict.to_list
  |> list.filter_map(fn(x) {
    let #(pos, char) = x
    case char {
      "[" -> Ok(100 * pos.x + pos.y)
      _ -> Error(Nil)
    }
  })
  |> int.sum
}
