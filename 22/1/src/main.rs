fn main() {
    let mut nums = include_str!("../input.txt")
        .split("\n\n")
        .map(|game| {
            game.lines()
                .map(|val| val.parse::<i32>().unwrap())
                .sum::<i32>()
        })
        .collect::<Vec<i32>>();
    nums.sort_by(|x, y| y.cmp(x));
    println!("{}", nums.iter().max().unwrap());
    println!("{}", nums[0..3].iter().sum::<i32>());
}
