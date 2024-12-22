import day22
import gleeunit/should

const example_p1 = "
1
10
100
2024
"

const example_p2 = "
1
2
3
2024
"

pub fn part1_test() {
  day22.part1(example_p1) |> should.equal(37_327_623)
}

pub fn part2_test() {
  day22.part2(example_p2)
  |> should.equal(23)
}
