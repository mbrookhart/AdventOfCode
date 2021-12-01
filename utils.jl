using DelimitedFiles

function read_col_vector(filename)
  open(readdlm, filename)[:, 1]
end
