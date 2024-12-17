import day17
import gleeunit/should

const example_p1 = "
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"

const example_p2 = "
Register A: 2214592
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
"

pub fn part1_test() {
  day17.part1(example_p1) |> should.equal("4,6,3,5,6,3,5,2,1,0")
}

pub fn part2_test() {
  day17.part2(example_p2)
  |> should.equal(117_440)
}
