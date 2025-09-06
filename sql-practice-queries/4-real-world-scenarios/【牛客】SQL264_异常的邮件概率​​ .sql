/*
 * 题目：SQL264 异常的邮件概率
 * 来源：牛客网
 * 难度：较难
 * 通过率：24.49%
 * 知识点：多表关联查询、条件过滤、分组统计、ROUND函数
 * 归类：3-real-world-scenarios/（真实业务场景）
 * 链接：https://www.nowcoder.com/practice/d6dd656483b545159d3aa89b4c26004e?tpId=82&tqId=35083&rp=1&sourceUrl=%2Fexam%2Foj%3Fpage%3D2%26tab%3DSQL%25E7%25AF%2587%26topicId%3D82&difficulty=undefined&judgeStatus=undefined&tags=&title=
 */

-- ================= 题目描述 =================
/*
需求：统计正常用户发送给正常用户邮件失败的概率
涉及表：
1. email表（邮件记录）
   - id, send_id, receive_id, type(completed/no_completed), date
2. user表（用户信息）
   - id, is_blacklist(0正常/1黑名单)

输出要求：
- 按日期升序
- 显示日期和失败概率(保留3位小数)
- 只统计正常用户间的邮件
*/

-- ================= 解题思路 =================
/*
核心逻辑：
1. 过滤有效邮件：发送方和接收方都必须是正常用户（is_blacklist=0）
2. 按日期分组统计：
   - 分子：统计每天失败的邮件数（type='no_completed'）
   - 分母：统计每天总邮件数
3. 计算失败概率：ROUND(失败数/总数, 3)
4. 处理除零问题：SQLite中1/2=0，需用1.0/2
*/

-- ================= SQL解答 =================
SELECT
    e.date,
    ROUND(
        SUM(IF(e.type = 'no_completed', 1, 0)) * 1.0 / COUNT(1)
        , 3
    ) AS p
FROM
    email AS e
WHERE
    send_id NOT IN (SELECT id FROM user WHERE is_blacklist = 1)
    AND receive_id NOT IN (SELECT id FROM user WHERE is_blacklist = 1)
GROUP BY
    e.date
ORDER BY
    e.date ASC;

-- ================= 优化思考 =================
/*
1. 性能优化：用JOIN替代子查询？
   SELECT e.date, ROUND(...)
   FROM email e
   JOIN user s ON e.send_id = s.id AND s.is_blacklist = 0
   JOIN user r ON e.receive_id = r.id AND r.is_blacklist = 0
   GROUP BY e.date

2. 可读性优化：使用CASE WHEN替代IF
   SUM(CASE WHEN e.type = 'no_completed' THEN 1 ELSE 0 END)
*/

-- ================= 优化SQL解答 =================
select 
    e.date
    , round(
        sum(case when e.type = 'no_completed' then 1 else 0 end)/count(1)
        , 3
    ) as p 
from
    email as e 
    inner join user as u1 on e.send_id = u1.id and u1.is_blacklist = 0
    inner join user as u2 on e.receive_id = u2.id and u2.is_blacklist = 0
group by e.date
order by e.date 
;
    