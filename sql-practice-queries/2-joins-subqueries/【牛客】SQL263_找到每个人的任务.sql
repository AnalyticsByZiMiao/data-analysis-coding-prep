/*
 * 题目：SQL263 找到每个人的任务
 * 来源：牛客网
 * 难度：简单
 * 通过率：42.46%
 * 时间限制：1秒
 * 空间限制：32M
 * 题号：SQL263
 * 链接：https://www.nowcoder.com/practice/9dd9182d029a4f1d8c1324b63fc719c9?tpId=82&tqId=35081&rp=1&sourceUrl=%2Fexam%2Foj%3Fpage%3D2%26tab%3DSQL%25E7%25AF%2587%26topicId%3D82&difficulty=undefined&judgeStatus=undefined&tags=&title=
 */

-- ================= 题目描述 =================
/*
有两个表：
1. person表（人员表）
   - id (主键)
   - name (姓名)

2. task表（任务表）
   - id (主键)
   - person_id (关联person.id)
   - content (任务内容)

要求：
1. 查询每个人的任务情况（没有任务的也要显示）
2. 输出字段：person.id, person.name, task.content
3. 按person.id升序排序
4. 没有任务时content显示为NULL
*/

-- ================= 表结构示例 =================
/*
CREATE TABLE `person` (
  `id` int(4) NOT NULL,
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`id`));

CREATE TABLE `task` (
  `id` int(4) NOT NULL,
  `person_id` int(4) NOT NULL,
  `content` varchar(32) NOT NULL,
  PRIMARY KEY (`id`));
*/

-- ================= 考察知识点 =================
/*
1. 左连接(LEFT JOIN)的使用：确保没有任务的人员也能显示
2. 排序(ORDER BY)的使用
3. NULL值的处理
*/

-- ================= 解题思路 =================
/*
核心逻辑：
1. 以person表为左表，确保所有人都会出现在结果中
2. 通过LEFT JOIN关联task表，关联条件为person.id = task.person_id
3. 按person.id升序排序
4. 注意：当person没有任务时，task表的字段会自动显示为NULL
*/

-- ================= 最终SQL解答 =================
SELECT 
    p.id,
    p.name,
    t.content  -- 没有任务时会自动显示NULL
FROM 
    person AS p
LEFT JOIN 
    task AS t
ON 
    p.id = t.person_id
ORDER BY 
    p.id;

-- ================= 测试案例 =================
/*
输入数据：
INSERT INTO person VALUES
(1,'fh'),
(2,'tm');

INSERT INTO task VALUES
(1,2,'tm works well'),
(2,2,'tm works well');

预期输出：
id | name | content
---+------+-------------
1  | fh   | NULL
2  | tm   | tm works well
2  | tm   | tm works well
*/

-- ================= 学习要点 =================
/*
1. LEFT JOIN 是解决"包含所有左表记录"问题的关键
2. 结果中person.id=2有两条记录，说明该人员有多个任务
3. 对比：
   - INNER JOIN 会过滤掉没有任务的人员
   - RIGHT JOIN 会以task表为主（不符合本题要求）
*/