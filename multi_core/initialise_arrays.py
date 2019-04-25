

startOfString = "var_insn_mem("
lengthOfArray = 64
endOfString = ")  := X\"00000\";"

for i in range(lengthOfArray):
    print(startOfString + str(i) + endOfString)
