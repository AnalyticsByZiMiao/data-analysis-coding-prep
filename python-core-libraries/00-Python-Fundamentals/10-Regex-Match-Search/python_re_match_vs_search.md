# RE 模块中的 match() 与 search() 

## match() 与 search() 特性对比
```

| 特性 | match() | search() |
|| 特性 | `re.search()` | `re.match()` |
|------|----------------|--------------|
| **功能** | 在字符串中搜索第一个匹配 | 检查字符串开头是否匹配 |
| **搜索范围** | 整个字符串 | 仅字符串开头 |
| **返回值（匹配时）** | Match 对象 | Match 对象 |
| **返回值（不匹配时）** | None | None |
| **匹配位置** | 字符串任意位置 | 必须从索引0开始 |
| **等价正则** | 无特定要求 | 相当于在正则前加 `^` |
| **典型用途** | 在文本中查找模式 | 验证字符串格式/前缀 |

```


## 代码对比

``` python

import re

text = "202509280115_sensor_data.csv"

# 使用 match() - 仅从开头匹配
match_result = re.match(r'\d{12}', text)  # 匹配12位数字（日期时间）
if match_result:
    print("Match found:", match_result.group())  # 输出：202509280115
else:
    print("Match not found at the beginning.")

# 使用 search() - 在整个字符串中搜索
search_result = re.search(r'sensor', text)  # 搜索 'sensor' 这个词
if search_result:
    print("Search found:", search_result.group())  # 输出：sensor
else:
    print("Pattern not found in the string.")


``` 
