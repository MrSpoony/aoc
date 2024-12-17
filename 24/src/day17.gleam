import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input17.txt")
  part1(input) |> io.println
  part2(input) |> int.to_string |> io.println
}

type Memory {
  Memory(a: Int, b: Int, c: Int, ip: Int, out: List(Int))
}

fn parse(input: String) {
  let assert Ok(#(regs, program)) =
    input |> string.trim |> string.split_once("\n\n")
  let assert Ok(program) =
    program
    |> string.drop_start(string.length("Program: "))
    |> string.split(",")
    |> list.map(int.parse)
    |> result.all
  let assert Ok(regs) =
    regs
    |> string.split("\n")
    |> list.map(fn(s) {
      s |> string.drop_start(string.length("Register X: ")) |> int.parse
    })
    |> result.all
  let assert Ok(a) = regs |> list.first
  let assert Ok(b) = regs |> list.drop(1) |> list.first
  let assert Ok(c) = regs |> list.drop(2) |> list.first
  #(Memory(a, b, c, 0, []), program)
}

fn get_num(operand: Int, mem: Memory) {
  case operand {
    0 | 1 | 2 | 3 | 7 -> operand
    4 -> mem.a
    5 -> mem.b
    6 -> mem.c
    _ -> panic as "only accepts 3-bit numbers"
  }
}

fn operate(opcode: Int, operand: Int, mem: Memory) {
  let Memory(a, b, c, _, out) = mem
  let div = fn() {
    a
    / {
      int.power(2, get_num(operand, mem) |> int.to_float)
      |> result.unwrap(0.0)
      |> float.round
    }
  }
  case opcode {
    0 -> Memory(..mem, a: div())
    1 -> Memory(..mem, b: int.bitwise_exclusive_or(b, get_num(operand, mem)))
    2 -> Memory(..mem, b: get_num(operand, mem) % 8)
    3 ->
      case a == 0 {
        True -> mem
        False -> Memory(..mem, ip: get_num(operand, mem))
      }
    4 -> Memory(..mem, b: int.bitwise_exclusive_or(b, c))
    5 -> Memory(..mem, out: [get_num(operand, mem) % 8, ..out])
    6 -> Memory(..mem, b: div())
    7 -> Memory(..mem, c: div())
    _ -> panic as "only accepts 3-bit numbers"
  }
}

fn run(allops: List(Int), mem: Memory) {
  let operations = allops |> list.drop(mem.ip)
  case operations {
    [opcode, operand, ..] -> {
      let newmem = operate(opcode, operand, mem)
      let ipinc = bool.to_int(newmem.ip == mem.ip) * 2
      run(allops, Memory(..newmem, ip: newmem.ip + ipinc))
    }
    _ -> mem
  }
}

// In my input every number depends on the last 7+3=10 bits,
// This means it also affects the last 4 numbers, that must match
fn find_a(allops: List(Int), mem: Memory, rest: List(Int), last: Int) {
  case rest {
    [] -> last
    [head, second, third, fourth, ..rest] ->
      find_a(
        allops,
        mem,
        [second, third, fourth, ..rest],
        list.range(0, 8 * 8 * 8 * 8)
          |> list.find_map(fn(x) {
            let new_a = last * 8 + x
            let newmem = run(allops, Memory(..mem, a: new_a))
            let newout = newmem.out |> list.reverse |> list.take(4)
            case newout == [fourth, third, second, head] {
              True -> Ok(new_a)
              False -> Error(Nil)
            }
          })
          |> result.lazy_unwrap(fn() {
            panic as "shouldn't happen (famous last words)"
          }),
      )
    _ -> last
  }
}

pub fn part1(input: String) {
  let #(mem, program) = parse(input)
  let regs = run(program, mem)
  regs.out |> list.reverse |> list.map(int.to_string) |> string.join(",")
}

pub fn part2(input: String) {
  let #(mem, program) = parse(input)
  let a = find_a(program, mem, program |> list.reverse, 0)
  let assert True =
    run(program, Memory(..mem, a: a)).out
    |> list.reverse
    == program
  a
}
