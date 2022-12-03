use std::collections::HashSet;

fn main() {
    println!(
        "{}",
        include_str!("../input.txt")
        .lines()
        .map(|line| {
            let mut set = HashSet::new();
            for (i, char) in line.chars().into_iter().enumerate() {
                if i < line.len()/2 {
                    set.insert(char);
                } else if set.contains(&char) {
                    return char_to_int(char)
                }
            }
            assert!(false, "Unreachable");
            return char_to_int('A')
        })
        .sum::<u32>()
    );
    let lines = include_str!("../input.txt").lines();
    let mut sets: Vec<Vec<HashSet<char>>> = Vec::new();
    let mut sum = 0;
    for (i, line) in lines.into_iter().enumerate() {
        let set_nr = i/3;
        if i%3 == 0 {
            sets.push(Vec::new());
            sets[set_nr].push(HashSet::new());
            sets[set_nr].push(HashSet::new());
        }
        for char in line.chars() {
            if i%3 == 0 {
                sets[set_nr][0].insert(char);
            } else if i%3 == 1 && sets[set_nr][0].contains(&char) {
                sets[set_nr][1].insert(char);
            } else if i%3 == 2 && sets[set_nr][1].contains(&char) {
                sum += char_to_int(char);
                break;
            }
        }
    }
    println!("{}", sum);
}

fn char_to_int(c: char) -> u32 {
    if c >= 'a' && c <= 'z' {
        c as u32 - 'a' as u32 + 1
    } else if c >= 'A' && c <= 'Z' {
        c as u32 - 'A' as u32 + 27
    } else {
        panic!("Invalid char");
    }
}
