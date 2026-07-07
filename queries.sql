-- 聚合函数（count、sum、avg、max、min）

SELECT COUNT(*) AS 包裹总数 FROM package;
SELECT MAX(warehouse_time) AS 最晚入库,MIN(warehouse_time)AS 最早入库 FROM package;
-- tips：加入包裹重量或费用，使用avg和sum
-- count(*)和count（列名）区别：count（列名）会忽略null
SELECT COUNT(DISTINCT emp_id) FROM package;
SELECT COUNT(out_time) AS 有出库时间的包裹数 FROM package;

-- group by
SELECT STATUS AS 状态,COUNT(*) AS 数量 FROM package GROUP BY STATUS;
SELECT courier_id,COUNT(*) AS 派送数量 FROM package GROUP BY courier_id;
-- 多列分组
SELECT courier_id,STATUS,COUNT(*) AS 数量 FROM package GROUP BY courier_id,STATUS;
-- order by
SELECT emp_id,COUNT(*) AS 处理数量 FROM package GROUP BY emp_id ORDER BY 处理数量 DESC;
SELECT package_id,warehouse_time FROM package  ORDER BY warehouse_time ;

-- having过滤分组结果
SELECT courier_id,COUNT(*) AS 派送数量 FROM package GROUP BY courier_id HAVING COUNT(*)>2;


-- 聚合函数和null值


-- 子查询
-- where子查询
SELECT package_no, sender_id, receiver_id, courier_id, emp_id, type_id, pickup_code, STATUS, warehouse_time, out_time
FROM package WHERE courier_id=(SELECT courier_id FROM courier WHERE courier_name='顺丰快递员');
-- where子查询（返回多值）in/not in
SELECT package_no, sender_id, receiver_id, courier_id, emp_id, type_id, pickup_code, STATUS, warehouse_time, out_time
FROM package WHERE type_id IN (SELECT type_id FROM express_type WHERE type_name IN('普通快递','加急快递'));

SELECT package_no, sender_id, receiver_id, courier_id, emp_id, type_id, pickup_code, STATUS, warehouse_time, out_time
FROM package WHERE type_id NOT IN (SELECT type_id FROM express_type WHERE type_name ='京东快递');
-- exists子查询
-- 查询"处理过包裹"的员工
SELECT emp_name 
FROM employee e
WHERE EXISTS (
  SELECT 1 FROM package p 
  WHERE p.emp_id = e.emp_id   -- 关键：关联外层的 e.emp_id
);
-- NOT EXISTS：没处理过包裹的员工（目前数据里没有，但语句是对的）
SELECT emp_name 
FROM employee e
WHERE NOT EXISTS (
  SELECT 1 FROM package p 
  WHERE p.emp_id = e.emp_id
);-- 用来找"不存在关联数据"的记录。比如查从来没处理过包裹的员工，用 NOT EXISTS 比 NOT IN 更安全，因为 NOT IN 遇到 NULL 值会出问题。

-- from 子查询(派生表)
SELECT * FROM (
SELECT STATUS,COUNT(*)AS 数量
FROM package
GROUP BY STATUS
)AS 状态统计
WHERE 数量>1;

SELECT STATUS,COUNT(*)AS 数量
FROM package
GROUP BY STATUS
HAVING 数量>1;

-- 查询每个包裹，同时显示该快递员的姓名-- 可用左外连接
SELECT package_no,STATUS,(SELECT courier_name FROM courier WHERE courier_id = p.courier_id) AS 快递员姓名
FROM package p;

-- 非相关子查询：内层查询独立运行，只执行一次
SELECT * FROM package
WHERE type_id = (
  SELECT type_id FROM express_type WHERE type_name = '普通快递'
);

-- 相关子查询：内层查询引用外层表，每行执行一次
SELECT * FROM package p
WHERE (
  SELECT courier_name FROM courier c WHERE c.courier_id = p.courier_id
) = '极兔快递员';
-- 内层查询没办法独立运行，它必须依赖外层传进来的数据。外层有多少行数据，括号里面的子查询就得被迫营业多少次。

-- 子查询与join对比
-- 子查询写法
SELECT package_no FROM package
WHERE courier_id = (
  SELECT courier_id FROM courier WHERE courier_name = '极兔快递员'
);

-- JOIN 等价写法（性能通常更好）
SELECT p.package_no
FROM package p
JOIN courier c ON p.courier_id = c.courier_id
WHERE c.courier_name = '极兔快递员';

-- 两层嵌套：找出处理过"顺丰速运"类型包裹的员工姓名
SELECT emp_name FROM employee
WHERE emp_id IN (
  SELECT emp_id FROM package
  WHERE type_id = (
    SELECT type_id FROM express_type WHERE type_name = '普通快递'
  )
);