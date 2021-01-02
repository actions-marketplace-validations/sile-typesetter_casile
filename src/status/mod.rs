use crate::*;

use git2::{DescribeFormatOptions, DescribeOptions};
use regex::Regex;
use std::{env, path};

// FTL: help-subcommand-status
/// Dump what we know about the repo
pub fn run() -> Result<()> {
    show_header("status-header");
    CONF.set_bool("verbose", true)?;
    setup::is_setup()?;
    Ok(())
}

#[allow(dead_code)]
#[derive(Debug)]
enum RunAsMode {
    RunAsDirectory,
    RunAsDocker,
    RunAsRunner,
    RunAsSystem,
}

#[allow(dead_code)]
/// Determine the runtime mode
fn run_as() -> RunAsMode {
    RunAsMode::RunAsDocker {}
}

/// Check to see if we're running in GitHub Actions
pub fn is_gha() -> Result<bool> {
    let ret = match env::var("GITHUB_ACTIONS") {
        Ok(_) => true,
        Err(_) => false,
    };
    display_check("status-is-gha", ret);
    Ok(ret)
}

/// Figure out if we're running inside Docker or another container
pub fn is_container() -> bool {
    let dockerenv = path::Path::new("/.dockerenv");
    dockerenv.exists()
}

pub fn get_gitname() -> Result<String> {
    fn origin() -> Result<String> {
        let repo = get_repo()?;
        let remote = repo.find_remote("origin")?;
        let url = remote.url().unwrap();
        let re = Regex::new(r"^(.*/)([^/]+?)(/?(\.git)?/?)$").unwrap();
        let name = re
            .captures(url)
            .ok_or(Error::new("error-no-remote"))?
            .get(2)
            .ok_or(Error::new("error-no-remote"))?
            .as_str();
        Ok(String::from(name))
    }
    fn path() -> Result<String> {
        let path = &CONF.get_string("path")?;
        let file = path::Path::new(path)
            .file_name()
            .ok_or(Error::new("error-no-path"))?
            .to_str();
        Ok(file.unwrap().to_string())
    }
    let default = Ok(String::from("casile"));
    origin().or(path().or(default))
}

/// Scan for existing makefiles with CaSILE rules
pub fn get_rules() -> Result<Vec<path::PathBuf>> {
    let repo = get_repo()?;
    let root = repo.workdir().unwrap();
    let files = vec!["GNUMakefile", "makefile", "Makefile", "rules.mk"];
    let mut rules = Vec::new();
    for file in &files {
        let p = root.join(file);
        if p.exists() {
            rules.push(p);
        }
    }
    Ok(rules)
}

/// Figure out version string from repo tags
pub fn get_git_version() -> String {
    let zero_version = String::from("0.000");
    let repo = get_repo().unwrap();
    let mut opts = DescribeOptions::new();
    opts.describe_tags().pattern("*[0-9].[0-9][0-9][0-9]");
    let desc = match repo.describe(&opts) {
        Ok(a) => {
            let mut fmt = DescribeFormatOptions::new();
            fmt.always_use_long_format(true);
            a.format(Some(&fmt)).unwrap()
        }
        Err(_) => {
            let head = repo.revparse("HEAD").unwrap();
            let mut revwalk = repo.revwalk().unwrap();
            revwalk.push_head().unwrap();
            let ahead = revwalk.count();
            let sha = head.from().unwrap().short_id().unwrap();
            format!("{}-{}-g{}", zero_version, ahead, sha.as_str().unwrap())
        }
    };
    let prefix = Regex::new(r"^v").unwrap();
    let sep = Regex::new(r"-").unwrap();
    String::from(sep.replace(&prefix.replace(desc.as_str(), ""), "-r"))
}