# SQL267 牛客新登录用户次日留存率解题笔记

## 📌 题目描述
计算牛客网新登录用户的次日成功的留存率，即第1天登陆之后，第2天再次登陆的概率。结果保留3位小数。

**输入表：login**
| 字段名    | 类型    | 描述          |
|-----------|---------|---------------|
| id        | int     | 主键          |
| user_id   | int     | 用户ID        |
| client_id | int     | 客户端ID      |
| date      | date    | 登录日期      |

**输出结果：**
| 字段 | 类型     | 描述        |
|------|----------|-------------|
| p    | decimal  | 次日留存率  |

**示例输出：**
 p
 0.500

## 🔍 解题思路分析
次日留存率 = (第1天新登录且第2天也登录的用户数) / (第1天新登录的用户总数)

**关键步骤：**
1.  **识别新用户**：找到每个用户的首次登录日期
2.  **匹配次日行为**：检查这些新用户在首次登录的次日是否有登录记录
3.  **计算比率**：统计满足条件的用户比例

## 🛠 优化后的SQL代码

WITH first_login AS (

-- 获取每个用户的首次登录日期

SELECT

user_id,

MIN(date) AS first_date

FROM login

GROUP BY user_id

),

next_day_login AS (

-- 检查哪些用户在首次登录的次日有登录记录

SELECT

f.user_id

FROM first_login f

INNER JOIN login l ON f.user_id = l.user_id

AND l.date = DATE_ADD(f.first_date, INTERVAL 1 DAY)

)

-- 计算留存率

SELECT

ROUND(

COUNT(DISTINCT n.user_id) * 1.0 / COUNT(DISTINCT f.user_id),

3

) AS p

FROM first_login f

LEFT JOIN next_day_login n ON f.user_id = n.user_id;

## 💡 关键知识点总结
### 1. 核心SQL技巧
- **CTE（Common Table Expressions）**：使用`WITH`语句创建临时表，提高代码可读性和可维护性
- **聚合函数**：`MIN(date)`用于查找每个用户的首次登录日期
- **日期函数**：`DATE_ADD(date, INTERVAL 1 DAY)`用于计算次日日期
- **表连接**：`INNER JOIN`用于匹配次日登录记录，`LEFT JOIN`用于保留所有新用户
- **舍入函数**：`ROUND(value, 3)`用于保留3位小数

### 2. 业务逻辑理解
- **留存率定义**：准确把握"新用户"和"次日"两个关键概念
- **数据去重**：使用`DISTINCT`确保用户唯一计数，避免重复登录记录影响结果
- **除法处理**：使用`* 1.0`确保进行浮点数除法而非整数除法

### 3. 易错点
- **分母错误**：误将全部用户作为分母，而非仅新用户
- **日期匹配**：忽略同用户多设备登录情况，需按用户ID和日期匹配
- **小数处理**：忘记乘以1.0导致整数除法结果为0

## 📊 扩展思考
### 如何计算多日留存率？
可通过修改日期间隔计算3日、7日、30日留存率：
AND l.date = DATE_ADD(f.first_date, INTERVAL 7 DAY) -- 7日留存

### 如何分平台计算留存率？
添加`client_id`分组维度：

SELECT

f.client_id,

ROUND(COUNT(DISTINCT n.user_id) * 1.0 / COUNT(DISTINCT f.user_id), 3) AS p

FROM first_login f

LEFT JOIN next_day_login n ON f.user_id = n.user_id

GROUP BY f.client_id;

## 📁 学习建议
1.  **掌握窗口函数**：使用`ROW_NUMBER()`可替代`GROUP BY`方案获取首次登录日期：

SELECT user_id, date

FROM (

SELECT *,

ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date) AS rn

FROM login

) t

WHERE rn = 1

2.  **理解连接类型**：
- `INNER JOIN`：确保只保留有次日登录的用户
- `LEFT JOIN`：保留所有新用户（确保分母正确）
3.  **练习类似题目**：在牛客网、LeetCode上练习更多留存率相关题目

