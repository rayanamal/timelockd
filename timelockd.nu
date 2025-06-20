#!/usr/bin/env nu

const dtlp: path = '/home/username/.local/bin/dtlp'
const files_dir: path = '/home/username/timelock'

# - Autostarted by a systemd service, when there is a .timelock file at a certain directory.
# 
# - main loop:
#       scan .timelock files
#       match them with the jobs:
#           create job if there is a file without a job (meaning the user put in a file)
#           delete job if there is a job without file (meaning the user deleted a file)
#       if there are no jobs still, exit
#       else, sleep 1 min

loop {
    cd $files_dir
    
    let files = ls | get name | filter { str ends-with '.timelock' }
    let jobs = job list | get tag
    
    $files |
    each {|file|
        let filename = $file | path parse | get stem 
        if $filename not-in $jobs {
            job spawn --tag $filename {
                run-external $dtlp '-i' $file '-o' ($filename + '.txt') | ignore
                rm $file
            }
        }
    }
    
    $jobs
    | each {|job|
        if $job not-in $files {
            let id = job list | where tag == $job | get id
            # The id might be empty in the extreme edge case where a job will finish and delete its source file after
            # it has been recorded in the $jobs variable.
            if ($id | is-not-empty) {
                job kill $id.0
            }
        }
    }
    
    if (job list | is-empty) {
        exit
    } else {
        sleep 1min
    }
}