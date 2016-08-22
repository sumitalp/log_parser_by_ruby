def mean(array)
  array.inject(0.0) { |sum, x| sum += x} / array.size
end

def median(array, already_sorted=false)
  return nil if array.empty?
  array = array.sort unless already_sorted
  m_pos = array.size / 2
  return array.size % 2 == 1 ? array[m_pos] : mean(array[m_pos-1..m_pos])
end

def mode(array)
  freq = array.inject(Hash.new(0)) { |h,v| h[v] += 1; h}
  max = freq.values.max                   # we're only interested in the key(s) with the highest frequency
  freq.select { |k, f| f == max }         # extract the keys that have the max frequency
end

def most_common_value(a)
  freq = Hash.new
  a.each do |x|
    if freq[x]
      freq[x] += 1
    else
      freq[x] = 1
    end
  end
  max = freq.values.max                   # we're only interested in the key(s) with the highest frequency
  freq.select { |k, f| f == max }         # extract the keys that have the max frequency
end

