

startOfString = "var_data_mem("
lengthOfArray = 256
endOfString = ")  := X\"0000\";"

for i in range(lengthOfArray):
    print(startOfString + str(i) + endOfString)
