use std::collections::HashSet;

fn main() {
    let lines = include_str!("../input.txt").lines();
    println!(
        "{}",
        lines
            .clone()
            .map(|line| {
                let mut set = HashSet::new();
                for (i, char) in line.chars().into_iter().enumerate() {
                    if i < line.len() / 2 {
                        set.insert(char);
                    } else if set.contains(&char) {
                        return char_to_int(char);
                    }
                }
                unreachable!();
            })
            .sum::<u32>()
    );
    let mut sets: Vec<Vec<HashSet<char>>> =
        vec![vec![HashSet::new(); 2]; lines.clone().count() / 3];
    let mut sum = 0;
    for (i, line) in lines.into_iter().enumerate() {
        let set_nr = i / 3;
        for char in line.chars() {
            match i % 3 {
                0 => {
                    sets[set_nr][0].insert(char);
                }
                1 if sets[set_nr][0].contains(&char) => {
                    sets[set_nr][1].insert(char);
                }
                2 if sets[set_nr][1].contains(&char) => {
                    sum += char_to_int(char);
                    break;
                }
                _ => (),
            };
        }
    }
    println!("{}", sum);
}

fn char_to_int(c: char) -> u32 {
    match c {
        'a'..='z' => c as u32 - 'a' as u32 + 1,
        'A'..='Z' => c as u32 - 'A' as u32 + 27,
        _ => unreachable!("Invalid char"),
    }
}
