# SQL 题解：识别高价值充电站与头部用户

> **题目来源:** 面试题 | 问题1
> **难度:** ⭐⭐⭐⭐
> **关键词:** `#多表连接` `#窗口函数` `#分组排序` `#子查询` `#真实业务场景`

---

## 1. 题目重述

**目标**：
找出2023年第三季度（7月-9月）总充电收入排名前5的充电站，并显示：
1.  充电站信息
2.  平均订单金额（客单价）
3.  该站点的“头部用户”（在该站累计消费金额最高的前3位用户的 `user_id`）

**数据表结构**：

**`charging_records` (充电记录表)**
| 字段名 | 类型 | 描述 |
| :--- | :--- | :--- |
| `record_id` | int | 记录ID |
| `user_id` | int | 用户ID |
| `station_id` | int | 充电站ID |
| `start_time` | datetime | 开始充电时间 |
| `end_time` | datetime | 结束充电时间 |
| `energy_consumed` | decimal | 充电电量 (kWh) |
| `amount` | decimal | 订单金额 (元) |

**`station_info` (充电站信息表)**
| 字段名 | 类型 | 描述 |
| :--- | :--- | :--- |
| `station_id` | int | 充电站ID |
| `station_name` | varchar | 充电站名称 |
| `location` | varchar | 位置 |

---

## 2. 解题思路分析

本题需分两步完成：
1.  **筛选与聚合**：筛选Q3数据，按充电站分组，计算总收入并排序取前5。
2.  **识别头部用户**：对每个充电站，按用户分组聚合消费总额，并排序取前3。

**逻辑难点**：
-   需要在同一条查询中同时处理**充电站排名**和**用户排名**。
-   “头部用户”的排名范围仅限于**每个充电站内部**。

**技术选择**：
-   使用 `SUM()` 和 `GROUP BY` 进行聚合计算。
-   使用 `RANK()` 或 `ROW_NUMBER()` 窗口函数进行分组排名。
-   使用 `WHERE` 子句过滤时间。
-   使用 `INNER JOIN` 关联表以获取充电站名称。

---

## 3. 最终SQL代码
-- 【SQL】识别高价值充电站与用户

-- 目标：找出2023年Q3总收入前5的充电站及其头部用户(消费前3)

``` sql
SELECT

si.station_id,

si.station_name,

si.location,

SUM(cr.amount) AS total_income, -- 充电站总收入

AVG(cr.amount) AS avg_order_amount, -- 充电站平均订单金额

-- 使用字符串聚合函数，将头部用户的user_id拼接成一列显示

GROUP_CONCAT(

CASE WHEN user_rank <= 3 THEN cr.user_id ELSE NULL END

ORDER BY user_income DESC

SEPARATOR ', '

) AS top_users -- 头部用户ID列表

FROM

charging_records cr

INNER JOIN

station_info si ON cr.station_id = si.station_id

INNER JOIN

-- 子查询：计算每个用户在每个站的消费总额及站内排名

(

SELECT

station_id,

user_id,

SUM(amount) AS user_income,

RANK() OVER (

PARTITION BY station_id

ORDER BY SUM(amount) DESC

) AS user_rank

FROM

charging_records

WHERE

start_time >= '2023-07-01'

AND start_time < '2023-10-01'

GROUP BY

station_id, user_id

) user_income_rank

ON cr.station_id = user_income_rank.station_id

AND cr.user_id = user_income_rank.user_id

WHERE

cr.start_time >= '2023-07-01'

AND cr.start_time < '2023-10-01'

GROUP BY

si.station_id, si.station_name, si.location

ORDER BY

total_income DESC -- 按总收入降序排序

LIMIT 5; -- 限制结果为前5名

```
## 4. 关键知识点拆解

1.  **时间过滤**：
``` sql
WHERE cr.start_time >= '2023-07-01' AND cr.start_time < '2023-10-01'
```

使用 `>=` 和 `<` 是过滤时间范围的规范写法，确保包含整个第三季度。

2.  **多表连接 (JOIN)**：
使用 `INNER JOIN` 将订单表与电站信息表关联，以获取电站名称和位置。

3.  **窗口函数用于分组排名 (RANK)**：
``` sql
RANK() OVER (PARTITION BY station_id ORDER BY SUM(amount) DESC) AS user_rank
```

-   `PARTITION BY station_id`：在每个充电站内部进行排名。
-   `ORDER BY SUM(amount) DESC`：按用户消费总额降序排名。
-   使用 `RANK()` 处理并列情况（如消费额相同的用户排名相同）。

4.  **字符串聚合 (GROUP_CONCAT)**：
``` sql
GROUP_CONCAT(CASE WHEN user_rank <= 3 THEN user_id ELSE NULL END ORDER BY user_income DESC SEPARATOR ', ') AS top_users
```

-   这是一个非常实用的函数，用于将多个行的 `user_id` 合并到一个字段中，用逗号分隔，清晰易读。
-   `CASE` 语句确保只选择排名前3的用户。
-   `ORDER BY user_income DESC` 保证拼接顺序按消费额从高到低。

---

## 5. 备选方案与思考

**方案对比：使用公共表表达式 (CTE)**

``` sql
WITH user_ranking AS (

SELECT

station_id,

user_id,

SUM(amount) AS user_income,

RANK() OVER (PARTITION BY station_id ORDER BY SUM(amount) DESC) AS user_rank

FROM charging_records

WHERE start_time >= '2023-07-01' AND start_time < '2023-10-01'

GROUP BY station_id, user_id

),

station_ranking AS (

SELECT

cr.station_id,

SUM(cr.amount) AS total_income

FROM charging_records cr

WHERE cr.start_time >= '2023-07-01' AND cr.start_time < '2023-10-01'

GROUP BY cr.station_id

ORDER BY total_income DESC

LIMIT 5

)

SELECT

si.station_id,

si.station_name,

si.location,

sr.total_income,

AVG(cr.amount) AS avg_order_amount,

GROUP_CONCAT(

CASE WHEN ur.user_rank <= 3 THEN ur.user_id ELSE NULL END

ORDER BY ur.user_income DESC

SEPARATOR ', '

) AS top_users

FROM station_ranking sr

JOIN charging_records cr ON sr.station_id = cr.station_id

JOIN station_info si ON sr.station_id = si.station_id

JOIN user_ranking ur ON sr.station_id = ur.station_id AND cr.user_id = ur.user_id

WHERE cr.start_time >= '2023-07-01' AND cr.start_time < '2023-10-01'

GROUP BY si.station_id, si.station_name, si.location, sr.total_income

ORDER BY sr.total_income DESC;
```

*   **优点**：逻辑更清晰，模块化。先分别计算充电站排名和用户排名，最后合并。
*   **缺点**：代码稍长，需要扫描订单表多次。
*   **结论**：**首选主查询方案**，它更简洁高效。CTE方案在需要多次复用中间结果时更有优势。

---

## 6. 面试考点延伸

-   **考察核心**：对窗口函数 `PARTITION BY` 的深刻理解，以及解决复杂分组排序问题的能力。
-   **业务理解**：能否将“头部用户”、“高价值充电站”等业务概念转化为具体的数据查询逻辑。
-   **细节处理**：
    -   时间范围的边界处理（是否包含10月1日零点）。
    -   使用 `RANK()` 还是 `DENSE_RANK()` 或 `ROW_NUMBER()` 处理并列排名（本题 `RANK()` 更符合业务逻辑）。
    -   结果的呈现方式（使用 `GROUP_CONCAT` 是一种简洁优雅的方案）。
-   **扩展思考**：
    -   “如果某个充电站头部用户不足3人，查询结果会怎样？”（结果会正常显示少于3个user_id，符合逻辑）
    -   “如何修改查询以显示头部用户的具体消费金额？”（这需要更复杂的输出格式，可能需完全重构查询）