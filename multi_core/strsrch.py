pattern = "aycaycy"
stream = "aycaycaycyaayyccycaycayccyaycaycaycy"

prefix_table = []
prefix_table.insert(0, 0)
i = 1
j = 0

while(i < len(pattern)):
	while (j>0 and pattern[i] != pattern[j]):
		j = int(prefix_table[j-1])
	if pattern[i] == pattern[j]:
		j = j + 1
	prefix_table.append(j)
	i = i + 1

index_count = 0 # offset counter
search_count = 0 # result
for i in range(len(stream)):
	char = stream[i]
	if(char == pattern[index_count]):
		index_count = index_count + 1
		if (index_count == len(pattern)):
			search_count = search_count + 1
			index_count = 0
	else:
		while(index_count > 0 and pattern[index_count] != char):
			#print(str(index_count) + " " + str(prefix_table[index_count - 1]))
			index_count = prefix_table[index_count - 1]
		if(pattern[index_count] == char):
			index_count = index_count + 1

print(search_count)
