#一、基础插入功能

#1. 插入快递类型基础数据
INSERT INTO express_type (type_name, remark) 
VALUES ('普通快递','标准派送'),('加急快递','优先派送'),('生鲜快递','冷链运输');

#2. 插入用户信息基础数据
INSERT INTO user_info (user_name, phone, address) 
VALUES 
('张三','13800138001','北京市海淀区'),
('李四','13800138002','上海市浦东新区'),
('王五','13800138003','广州市天河区'),
('赵六','13800138004','深圳市南山区');

#3. 插入员工信息基础数据
INSERT INTO employee (emp_name, phone, POSITION) 
VALUES 
('陈经理','13900139001','站长'),
('周员工','13900139002','普通员工'),
('吴员工','13900139003','普通员工');

#4. 插入快递员基础数据
INSERT INTO courier (courier_name, phone, company) 
VALUES 
('顺丰快递员','13700137001','顺丰速运'),
('中通快递员','13700137002','中通快递'),
('圆通快递员','13700137003','圆通速递');

#5. 插入核心包裹基础数据（多种初始状态）
INSERT INTO package (package_no, sender_id, receiver_id, courier_id, emp_id, type_id, pickup_code, STATUS) 
VALUES
('SF123456',1,2,1,1,1,'A001','待取'),
('ZT789012',2,3,2,2,2,'B002','待取'),
('YT345678',3,4,3,3,3,'C003','已取'),
('SF901234',4,1,1,2,1,'D004','退回');