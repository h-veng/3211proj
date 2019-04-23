

startOfString = "var_insn_mem("
lengthOfArray = 64
endOfString = ")  := X\"0000\";"

for i in range(lengthOfArray):
    print(startOfString + str(i) + endOfString)
