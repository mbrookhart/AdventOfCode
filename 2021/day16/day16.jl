function to_bits(s)
  join(string.(parse.(Int64, collect(s), base=16), base=2, pad=4))
end

@assert to_bits("D2FE28") == "110100101111111000101000"

struct Value
  version
  type_id
  value
end

struct Operation
  version
  type_id
  inputs
end

function get_version(x::Value)
  return x.version
end

function get_version(x::Operation)
  version = x.version
  for input in x.inputs
    version += get_version(input)
  end
  version
end

function get_value(x::Value)
  x.value
end

function get_value(x::Operation)
  inputs = get_value.(x.inputs)
  funcs = Dict(
               0=>x->sum(x),
               1=>x->prod(x),
               2=>x->minimum(x),
               3=>x->maximum(x),
               5=>x->Int64(x[1] > x[2]),
               6=>x->Int64(x[1] < x[2]),
               7=>x->Int64(x[1] == x[2])
              )
  funcs[x.type_id](inputs)
end

function parse_packet(packet; searching_bits=false)
  version = parse(Int64, packet[1:3], base=2)
  type_id = parse(Int64, packet[4:6], base=2)
  outputs = Array{Any, 1}(undef, 0)
  packet_end = 0
  if type_id != 4
    length_type_id = packet[7]
    num_packets = 0
    packet_start = 0
    if length_type_id == '0'
      packet_end = 7 + 15
      nbits = parse(Int64, packet[8:packet_end], base=2)
      tmp_o, tmp_end = parse_packet(packet[packet_end + 1:packet_end + nbits], searching_bits=true)
      packet_end += nbits
      push!(outputs, Operation(version, type_id, tmp_o))
    else
      packet_end = 7 + 11
      num_packets = parse(Int64, packet[8:packet_end], base=2)
      inputs = Array{Any, 1}(undef, 0)
      for i in 1:num_packets
        if length(packet) - packet_end  > 8
          tmp_o, tmp_end = parse_packet(packet[packet_end + 1:length(packet)])
          packet_end += tmp_end
          append!(inputs, tmp_o)
        end
      end
      push!(outputs, Operation(version, type_id, inputs))
    end
  else
    n = 7
    val = ""
    while n <= length(packet) && packet[n] != '0'
      val *= packet[n+1:n + 4]
      n += 5
    end
    val *= packet[n+1:n + 4]
    packet_end = n + 4
    push!(outputs, Value(version, type_id, parse(Int64, val, base=2)))
  end
  if searching_bits
    if length(packet) - packet_end  > 8
      tmp_o, tmp_end = parse_packet(packet[packet_end + 1:length(packet)], searching_bits=true)
      packet_end += tmp_end
      append!(outputs, tmp_o)
    end
  end
  return outputs, packet_end
end

function load(file)
  lines = readlines(file)
  to_bits(lines[1])
end

function problem1(A)
  get_version(parse_packet(A)[1][1])
end

function problem2(A)
  graph = parse_packet(A)[1][1]
  get_value(graph)
end

if abspath(PROGRAM_FILE) == @__FILE__
  A = load("test1.txt")
  @assert problem1(A) == 16

  A = load("test2.txt")
  @assert problem1(A) == 12

  A = load("test3.txt")
  @assert problem1(A) == 23

  A = load("test4.txt")
  @assert problem1(A) == 31

  @assert problem2(to_bits("C200B40A82")) == 3
  @assert problem2(to_bits("04005AC33890")) == 54
  @assert problem2(to_bits("880086C3E88112")) == 7
  @assert problem2(to_bits("CE00C43D881120")) == 9
  @assert problem2(to_bits("D8005AC2A8F0")) == 1
  @assert problem2(to_bits("F600BC2D8F")) == 0
  @assert problem2(to_bits("9C005AC2F8F0")) == 0
  @assert problem2(to_bits("9C0141080250320F1802104A08")) == 1
  
  B = load("input.txt")
  println(problem1(B))
  println(problem2(B))
end
