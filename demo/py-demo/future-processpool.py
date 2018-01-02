import concurrent.futures, urllib.request,math
import multiprocessing

def is_prime(n):
    mid = int(math.sqrt(n))
    flag = True
    for i in range(3, mid+1,2):
        if n%i == 0:
            flag = False
            break
    return flag


# print(multiprocessing.Pool(4).apply_async(is_prime, (23,)).get())
nums = [25, 61, 29, 50, 109]
with concurrent.futures.ProcessPoolExecutor() as executor:
    for x in zip(nums, executor.map(is_prime, nums)):
        print(x)

with concurrent.futures.ProcessPoolExecutor() as executor:
    future_to_num = {executor.submit(is_prime, n ):n for n in nums}
    for future in concurrent.futures.as_completed(future_to_num):
        data = future.result()
        print(future_to_num[future],data)
    for i,j in future_to_num.items():
        print(i,j)
    print(future_to_num)

