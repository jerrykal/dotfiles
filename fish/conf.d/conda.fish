function conda --description "Lazy load conda"
    functions -e conda
    eval command conda "shell.fish" hook | source

    function __conda_add_prompt
    end

    conda $argv
end
