import day08
import gleeunit/should

const example = "
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"

pub fn part1_test() {
  day08.part1(example) |> should.equal(14)
}

pub fn part2_test() {
  day08.part2(example) |> should.equal(34)
}
