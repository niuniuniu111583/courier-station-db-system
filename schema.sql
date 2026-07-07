#快递驿站管理系统
CREATE DATABASE IF NOT EXISTS express_station 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_general_ci;
USE express_station;

#第一部分：数据库表结构设计、完整性约束、索引、视图设计

#快递类型表
CREATE TABLE IF NOT EXISTS express_type (
    type_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '快递类型ID(主键)',
    type_name VARCHAR(20) NOT NULL UNIQUE COMMENT '类型名称(非空唯一)',
    remark VARCHAR(50) DEFAULT '无备注' COMMENT '备注'
)COMMENT='快递类型表';
DESC express_type;

#用户表（寄件人/收件人）
CREATE TABLE IF NOT EXISTS user_info (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID(主键)',
    user_name VARCHAR(20) NOT NULL COMMENT '用户姓名',
    phone VARCHAR(11) NOT NULL UNIQUE COMMENT '手机号(非空唯一)',
    address VARCHAR(100) COMMENT '详细地址',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
)COMMENT='用户表';
DESC user_info;

#驿站员工表
CREATE TABLE IF NOT EXISTS employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID(主键)',
    emp_name VARCHAR(20) NOT NULL COMMENT '员工姓名',
    phone VARCHAR(11) NOT NULL UNIQUE COMMENT '手机号(唯一)',
    POSITION VARCHAR(20) DEFAULT '普通员工' COMMENT '岗位',
    entry_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '入职时间'
)COMMENT='驿站员工表';
DESC employee;

#快递员表
CREATE TABLE IF NOT EXISTS courier (
    courier_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '快递员ID(主键)',
    courier_name VARCHAR(20) NOT NULL COMMENT '快递员姓名',
    phone VARCHAR(11) NOT NULL UNIQUE COMMENT '手机号(唯一)',
    company VARCHAR(30) NOT NULL COMMENT '所属快递公司',
    entry_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '入职时间'
)COMMENT='快递员表';
DESC courier;

#核心包裹表（外键关联+检查约束）
CREATE TABLE IF NOT EXISTS package (
    package_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '包裹ID(主键)',
    package_no VARCHAR(30) NOT NULL UNIQUE COMMENT '快递单号(唯一)',
    sender_id INT NOT NULL COMMENT '寄件人ID(外键)',
    receiver_id INT NOT NULL COMMENT '收件人ID(外键)',
    courier_id INT NOT NULL COMMENT '派送快递员ID(外键)',
    emp_id INT NOT NULL COMMENT '入库操作员工ID(外键)',
    type_id INT NOT NULL COMMENT '快递类型ID(外键)',
    pickup_code VARCHAR(10) NOT NULL COMMENT '取件码',
    STATUS VARCHAR(10) NOT NULL DEFAULT '待取' CHECK (STATUS IN ('待取','已取','退回','丢失')),
    warehouse_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '入库时间',
    out_time DATETIME COMMENT '出库时间',
    remark VARCHAR(50) DEFAULT '无备注' COMMENT '备注',
    FOREIGN KEY (sender_id) REFERENCES user_info(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (receiver_id) REFERENCES user_info(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (courier_id) REFERENCES courier(courier_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (type_id) REFERENCES express_type(type_id) ON UPDATE CASCADE ON DELETE RESTRICT
)COMMENT='包裹信息表';
DESC package;

#索引设计（优化查询性能）  CREATE INDEX 索引名 ON 表名(字段名);
DROP INDEX idx_package_no ON package;
DROP INDEX idx_pickup_code ON package;
DROP INDEX idx_status ON package;
DROP INDEX idx_phone ON user_info;
CREATE INDEX idx_package_no ON package(package_no);
CREATE INDEX idx_pickup_code ON package(pickup_code);
CREATE INDEX idx_status ON package(STATUS);
CREATE INDEX idx_phone ON user_info(phone);

#视图设计（简化复杂查询）
#待取包裹视图
DROP VIEW IF EXISTS v_wait_pickup;
CREATE VIEW v_wait_pickup AS
SELECT p.package_no 快递单号, u.user_name 收件人, u.phone 收件人手机号, p.pickup_code 取件码, p.warehouse_time 入库时间, e.emp_name 操作员工
FROM package p JOIN user_info u ON p.receiver_id = u.user_id JOIN employee e ON p.emp_id = e.emp_id WHERE p.status = '待取';
#包裹状态统计视图
DROP VIEW IF EXISTS v_package_total;
CREATE VIEW v_package_total AS
SELECT STATUS 包裹状态, COUNT(*) 数量 FROM package GROUP BY STATUS;