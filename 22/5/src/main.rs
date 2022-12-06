fn main() {
    let text = include_str!("../input.txt")
        .split("\n\n")
        .collect::<Vec<_>>();
    let instructions = text[1]
        .lines()
        .map(|line| {
            line.split(" ")
                .filter_map(|x| x.parse::<i32>().ok())
                .collect::<Vec<i32>>()
        })
        .collect::<Vec<Vec<i32>>>();
    let mut stacks: Vec<Vec<char>> = vec![vec![]; text[0].lines().nth(0).unwrap().len() / 4 + 1];
    text[0]
        .lines()
        .rev()
        .skip(1)
        .map(|line| {
            line.chars()
                .enumerate()
                .filter_map(|(i, v)| if i % 4 == 1 { Some(v) } else { None })
        })
        .for_each(|stack| {
            stack
                .enumerate()
                .filter(|(_, c)| *c != ' ')
                .for_each(|(i, c)| stacks[i].push(c))
        });
    let mut st1 = stacks.clone();
    let mut st2 = stacks.clone();
    for instruction in instructions {
        let cnt = instruction[0];
        let from = (instruction[1] - 1) as usize;
        let to = (instruction[2] - 1) as usize;
        let mut to_move = vec![];
        for _ in 0..cnt {
            let what1 = st1[from][st1[from].len() - 1];
            let what2 = st2[from][st2[from].len() - 1];
            st1[from].pop();
            st2[from].pop();
            st1[to].push(what1);
            to_move.push(what2);
        }
        for c in to_move.iter().rev() {
            st2[to].push(*c);
        }
    }
    println!(
        "{}",
        st1.iter()
            .map(|stack| stack[stack.len() - 1])
            .collect::<String>()
    );
    println!(
        "{}",
        st2.iter()
            .map(|stack| stack[stack.len() - 1])
            .collect::<String>()
    );
}
