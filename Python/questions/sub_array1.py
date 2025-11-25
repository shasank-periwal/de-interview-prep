arr = [2,3,4,5,6,7,8]
size = len(arr)
k = 3

sum = 0
i = 0
j = 0
sub_arr = []

for j in range(size):
    if j-i+1 < k:
        sum += arr[j]
    elif j-i+1 == k: 
        sum += arr[j]
        sub_arr.append(sum)
        sum -= arr[i]
        i += 1

print(sub_arr)