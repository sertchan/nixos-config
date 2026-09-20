use std::fs::File;
use std::io::Read;
use std::process::{Command, Stdio};
use std::thread::sleep;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

const WALLPAPERS: &str = match option_env!("WALLPAPERS") {
    Some(list) => list,
    None => "",
};

const AWWW: &str = match option_env!("AWWW") {
    Some(path) => path,
    None => "awww",
};

const AWWW_DAEMON: &str = match option_env!("AWWW_DAEMON") {
    Some(path) => path,
    None => "awww-daemon",
};

const ROTATE_EVERY: Duration = Duration::from_secs(60 * 60);
const DAEMON_POLL: Duration = Duration::from_millis(100);
const DAEMON_POLL_LIMIT: u32 = 100;

const TRANSITION: [&str; 6] = [
    "--transition-type",
    "center",
    "--transition-duration",
    "0.7",
    "--transition-fps",
    "75",
];

fn daemon_ready() -> bool {
    Command::new(AWWW)
        .arg("query")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|status| status.success())
}

fn start_daemon() {
    if daemon_ready() {
        return;
    }

    if Command::new(AWWW_DAEMON)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .is_err()
    {
        eprintln!("awww-daemon failed to start");
        return;
    }

    for _ in 0..DAEMON_POLL_LIMIT {
        if daemon_ready() {
            return;
        }
        sleep(DAEMON_POLL);
    }

    eprintln!("awww-daemon answered no query before the wait ran out");
}

fn show(wallpaper: &str) {
    start_daemon();

    let shown = Command::new(AWWW)
        .arg("img")
        .arg(wallpaper)
        .args(TRANSITION)
        .status()
        .is_ok_and(|status| status.success());

    if !shown {
        eprintln!("awww refused {wallpaper}");
    }
}

fn entropy() -> u64 {
    let mut seed = [0u8; 8];

    if File::open("/dev/urandom")
        .and_then(|mut source| source.read_exact(&mut seed))
        .is_ok()
    {
        return u64::from_ne_bytes(seed);
    }

    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|since| since.as_nanos() as u64)
        .unwrap_or(0)
}

fn main() {
    let wallpapers: Vec<&str> = WALLPAPERS.lines().filter(|line| !line.is_empty()).collect();

    if wallpapers.is_empty() {
        eprintln!("no wallpaper was built into this binary");
        return;
    }

    let mut current = (entropy() % wallpapers.len() as u64) as usize;
    show(wallpapers[current]);

    if wallpapers.len() < 2 {
        return;
    }

    loop {
        sleep(ROTATE_EVERY);

        let last = current;
        while current == last {
            current = (entropy() % wallpapers.len() as u64) as usize;
        }

        show(wallpapers[current]);
    }
}
