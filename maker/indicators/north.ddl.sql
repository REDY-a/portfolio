SELECT indId, indName, parent, sort, fullpath, css, weight, qtype, remarks, extra
FROM ind_emotion;

drop table nebulae;

create table nebulae (
	nid      varchar2(12) NOT NULL,
	nebula   varchar2(50),
	nebutype varchar2(40) , -- a reference to a_domain.domainId (parent = 'a_orgs')

	parent   varchar2(12),
	sort     int DEFAULT 0,
	fullpath varchar2(200),

	PRIMARY KEY (nid)
);

delete from nebulae;
INSERT INTO nebulae
(nid,      parent,   nebula,        nebutype, sort,fullpath)
VALUES
('0',       NULL,    'Organization','',       '0', '0'      ),
('class',  '0',      'Class',       'student','0', '0.0'    ),
('ap01-22','class',  'AP 1 / 2022', 'student','0', '0.0.000'),
('ap02-22','class',  'AP 2 / 2022', 'student','1', '0.0.001'),
('ap01-23','class',  'AP 1 / 2023', 'student','2', '0.0.002'),
('ap02-23','class',  'AP 2 / 2023', 'student','3', '0.0.003'),

('teacher','0',      'Teacher Group','teacher','1', '0.1'    ),
('t01',   'teacher', 'Home Teacher', 'teacher','0', '0.1.000'),
('t02',   'teacher', 'STEM',         'teacher','1', '0.1.001'),
('t03',   'teacher', 'Counselor',    'teacher','2', '0.1.002'),

('home',  '0',       'Home',         'parent', '2', '0.2'    ),
('misc',  '0',       'Misc',         'parent', '2', '0.3'    );

drop table n_teaching;
create table n_teaching (
	teacher   varchar2(12) NOT NULL, -- user Id
	class     varchar2(12),          -- org Id (type = class)
	tyear     varchar(12)            -- teaching year
);

insert into n_teaching
(teacher, class,      tyear) values
('becky', 'ap01-22',  '2022'),
('becky', 'ap01-23',  '2023');

drop table n_mykids;
create table n_mykids (
	-- DESIGN NOTE: If a sqlite DB owned by a teacher, this table should only has records from filtered orgniations
	--
	userId TEXT(20) not null,
	userName TEXT(50) not null,
	roleId TEXT(20),
	orgId TEXT(20),
	nationId TEXT(20),
	counter int,
	birthday DATE,
	pswd TEXT NOT NULL,
	iv TEXT(200),
	CONSTRAINT a_users_pk PRIMARY KEY (userId)
);

delete from n_mykids;
﻿﻿INSERT INTO n_mykids
(userId,  userName,   roleId, orgId,   nationId, counter, birthday,  pswd,     iv) VALUES
('ody',   'Ody',      'r02',  'home',   'CN',    NULL,    1911-10-10,'123456', NULL),
('becky', 'Becky Du', 'r01',  't01',    'CN',    NULL,    2000-1-1,  '123456', NULL),
('george','George',   'r03',  'ap01-22','CN',    NULL,    2005-1-1,  '123456', NULL),
('alice', 'Alice',    'r03',  'ap01-22','CN',    NULL,    2016-1-1,  '123456', NULL);

drop table ind_emotion;
CREATE TABLE ind_emotion (
    -- indicator configuration
	indId      varchar2(12),
	templId    varchar2(12),     -- template Id (indicator category), use a letter (no domain table in north)
	indName    varchar2(64),
	parent     varchar2(12),
	sort       varchar2(4),      -- tree sibling sort
	fullpath   varchar2(256),
	css        varchar2(256),    -- special display format, e.g. icon
	weight     FLOAT,           -- default weight. A poll should have question weight independently
	qtype      varchar2(4),      -- question type (single, multiple answer, ...)
	remarks    varchar2(512),    -- used as quiz question
	qsort      intvarchar2 DEFAULT 0,   -- sort in a quiz
	expectings varchar2(512),    -- expected answers
	descrpt    varchar2(256),    -- a short description
	extra      varchar2(128),
	CONSTRAINT ind_emotion_PK PRIMARY KEY (indId)
);

drop table quizzes;
CREATE TABLE quizzes (
	-- quizzes records (master)
	-- a quiz is a polling events, with each user's polling instance as a record of "polls".
    qid        varchar(12) PRIMARY KEY,
    title      varcher(512),
    oper       varchar(12) NOT NULL,
    optime     NUMERIC NOT NULL,
    tags       varchar(200),
    quizinfo   varchar(2000),
    qowner     varchar(12),
    subject    varchar(12),
    dcreate    NUMERIC,
    pubTime    NUMERIC,
    extra      varchar(1000)
);

drop table questions;
CREATE TABLE questions (
	-- quizzes details (child of quizzes)
	-- some questions are copied from indicators, some are not
    qid        varchar2(12) PRIMARY KEY,
    quizId     varchar2(12) NOT NULL,
    indId      varchar2(12),           -- fk -> indicators.indId, nullable
    question   varchar2(2000),
    answers    varchar2(500) NOT NULL, -- a question doesn't have structured answers / options
    qtype      varchar2(12) NOT NULL,
    answer     varchar2(12),           -- This is a design error - a poll's results are stored in polldetails. The legacy is used as a buffer at client side.
    qorder     NUMERIC,
    prompt     VARCHAR2(512),          -- hint
    shortDesc  varchar2(256),          -- indicator name
    image      TEXT,
    hints      varchar2(1000),
    extra      varchar2(1000)
);

drop table polls;
CREATE TABLE polls (
    -- poll event, quiz's details table (child of quizzes)
	pid      varchar2(12),     -- poll id
	quizId   varchar2(12),     -- quiz id, fk -> quizzes.qid
	issuerId varchar2(12),
	userId   varchar2(12),     -- [optional] sys / regisetered user
	state    varchar2(4),      -- wait / done / poll(ing) / stop
	userInfo varchar2(1000),   -- temp user info, json?
	extra    varchar2(1000),   -- v0.1  {msg: 'message from north star'}
	CONSTRAINT polls_PK PRIMARY KEY (pid)
);

drop table polldetails;
CREATE TABLE polldetails (
	-- poll details (child of polls)
	quizId  varchar2(12),     -- quiz Id, check count when deleting quiz? pc-del?
	pollId  varchar2(12),     -- poll Id (fk semantics)
	questId varchar2(12),     -- question Id (fk semantics)
	userId  varchar2(12),
	indId   varchar2(12),
	results varchar2(1000),   -- answer or text (number value)

	CONSTRAINT polldetails_PK PRIMARY KEY (pollId, questId)
);

drop table connects;
CREATE TABLE connects (
	cid    varchar2(12) NOT NULL, -- auto key
	toId   varchar2(12),
	fromId varchar2(12),
	state  varchar2(4),           -- wait / done / poll(ing) / hide
    oper   varchar(12) NOT NULL,
    optime NUMERIC NOT NULL,
	hello  varchar2(1000),
	extra  varchar2(1000),
	CONSTRAINT polls_PK PRIMARY KEY (cid)
);

------------------------------------------------------------------------
drop view if exists v_qscount;
CREATE VIEW v_qscount AS SELECT
 	q.qid, count(qs.qid) qsNum, q.subject, q.title
 FROM
 	quizzes q join questions qs on q.qid = qs.quizId
 group by q.qid;

------------------------------------------------------------------------

delete from ind_emotion;

INSERT INTO ind_emotion
(indId, templId, indName,     remarks,        css,                 weight, fullpath,         qtype, expectings,   parent, sort)
VALUES
('i-1', 'B',	'Academic',  NULL,           '{icon: ''sys''}',     '.6', '1 i-1',         'cate', NULL,         'cate', 1),
('i-1.1', 'B',	'GPA 1',     '/sys/domain',   '',                   '.2', '1 sys.1 domain',   's', 'A. 1\\nB. 5','i-1',  1),
('i-1.2', 'B',	'GPA 2',     '/sys/roles',    '',                   '.2', '1 sys.2 role',     's', 'A\\nB\\nC',  'i-1',  2),
('i-1.3', 'B',	'GPA 3',     '/sys/orgs',     '',                   '.2', '1 sys.3 org',      's', 'A\\nB\\nC',  'i-1',  3),
('i-1.4', 'B',	'GPA 4',     '/sys/users',    '',                   '.2', '1 sys.4 user',     's', 'A\\nB\\nC',  'i-1',  4),
('i-1.5', 'B',	'GPA 5',     '/n/indicators', '',                   '.2', '1 sys.5 inds',     's', 'A\\nB\\nC',  'i-1',  5),

('j-1',   'B',	'AP Scores', NULL,            '',                   '.4', '2 j-1',         'cate', NULL,         'cate',  2),
('j-1.1', 'B',	'STEM',      '/n/dashboard',  '{icon: ''sms''}',    '.5', '2 j-1.1 j-1.1',    's', 'A\\nB\\nC',  'j-1',  1),
('j-1.2', 'B',	'Arts',      '/n/quizzes',    '{icon: ''send''}',   '.2', '2 j-1.2 j-1.2',    's', 'A\\nB\\nC',  'j-1',  2),
('j-1.3', 'B',	'Sociaty',   '/n/polls',      '{icon: ''paper''}',  '.1', '2 j-1.3 j-1.3',    's', 'A\\nB\\nC',  'j-1',  2),
('j-1.4', 'B',	'Business',  '/n/my-students','{icon: ''children''}','.2', '2 j-1.4 j-1.4',   's', 'A\\nB\\nC',  'j-1',  3),

('j-1.1.1','B',	'CS A',      'Computer Science A', '',            '.2', '2 j-1.1 j-1.1.1 j-1.1.1', 'n', 'A\\nB\\nC', 'j-1.1', 1),
('j-1.1.3','B',	'Physics BC','/c/status',     '{icon: ''sms''}',  '.3', '2 j-1.1 j-1.1.2 j-1.1.2', 'n', 'A\\nB\\nC', 'j-1.1', 2),
('j-1.1.4','B',	'Math',      '/c/myconn',     '{icon: ''send''}', '.2', '2 j-1.1 j-1.1.3 j-1.1.3', 'n', 'A\\nB\\nC', 'j-1.1', 3),
('j-1.1.5','B',	'CS B',      '/c/mypolls',    '{icon: ''sms''}',  '.2', '2 j-1.1 j-1.1.4 j-1.1.4', 'n', 'A\\nB\\nC', 'j-1.1', 4);

delete from a_role_func;
insert into a_role_func(funcId, roleId) select f.funcId, 'r01' from a_functions f;
insert into a_role_func(funcId, roleId) select f.funcId, 'r03' from a_functions f where f.funcId like 'c%';

SELECT f.funcId, parentId, funcName, url, sibling sort, fullpath, css, flags
FROM a_functions f join a_role_func rf on rf.funcId = f.funcId
join a_users u on u.roleId = rf.roleId and u.userId = 'george'
order by f.fullpath;

-- delete from ind_emotion where fullpath like 'A%';
INSERT INTO ind_emotion
(indId, templId, indName,   	parent,		sort,	fullpath,	css,	weight,	        qtype,  remarks,       	qsort,	expectings,	descrpt)
VALUES
('A',   '-A-',  'Test 1',	        '', 	0,  	'A',    	'', 	1.0,	        '',     'Test 1',       	0,  	'',    	'Test 1'),
('A01', 'A',    '学习压力',	        'A',	1,  	'A.01', 	'', 	0.1157024793,	'r5',  	'学习压力',	        0,	    '',    	'学习压力'),
('A02', 'A',	'父母/家庭关系',		'A',	1,	    'A.01',		'',	    0.0826446281,	'r5',  	'父母/家庭关系',		0,		'',   	'父母/家庭关系'),
('A03', 'A',	'朋友/人际关系',		'A',	2,	    'A.02',		'',	    0.0826446281,	'r5',  	'朋友/人际关系',		0,		'',     '朋友/人际关系'),
('A04', 'A',	'考试测试',	        'A',	3,  	'A.03',		'', 	0.0578512397, 	'r5',    '考试测试',     		0,		'',     '考试测试'),
('A05', 'A',	'恋爱/异性',	   		'A',	4,		'A.04',		'',	    0.0661157025,	'r5',    '恋爱/异性',			0,		'',     '恋爱/异性'),
('A06', 'A',	'追星/偶像',	   		'A',	5,		'A.05',		'',	    0.0578512397,	'r5',  	'追星/偶像',	    	0,		'',     '追星/偶像'),
('A07', 'A',	'学业',	            'A',	6,		'A.06',		'',		0.0495867769,	'r5',	'学业',				0,		'',		'学业'),
('A08', 'A',	'天气',	            'A',	7,		'A.07',		'',		0.041322314,	'r5',	'天气',				0,		'',		'天气'),
('A09', 'A',	'周边环境',	        'A',	8,		'A.08',		'',		0.0330578512,	'r5',	'周边环境',			0,		'',		'周边环境'),
('A10', 'A',	'托福成绩',	        'A',	9,		'A.09',		'',		0.0330578512,	'r5',	'托福成绩',			0,		'',		'托福成绩'),
('A11', 'A',	'猪队友/小组项目',		'A',	10,		'A.10',		'',		0.0330578512,	'r5',	'猪队友/小组项目',		0,		'',		'猪队友/小组项目'),
('A12', 'A',	'做不完的事情',	    'A',	11,		'A.11',		'',		0.0330578512,	'r5',	'做不完的事情',		0,		'',		'做不完的事情'),
('A13', 'A',	'烦人的规则',	   		'A',	12,		'A.12',		'',		0.0247933884,	'r5',	'烦人的规则',			0,		'',		'烦人的规则'),
('A14', 'A',	'朋友间的争吵',	    'A',	13,		'A.13',		'',		0.0247933884,	'r5',	'朋友间的争吵',		0,		'',		'朋友间的争吵'),
('A15', 'A',	'睡眠',	            'A',	14,		'A.14',		'',		0.0247933884,	'r5',	'睡眠',				0,		'',		'睡眠'),
('A16', 'A',	'财富自由',	        'A',	15,		'A.15',		'',		0.0247933884,	'r5',	'财富自由',			0,		'',		'财富自由'),
('A17', 'A',	'饮食',	            'A',	16,		'A.16',		'',		0.0247933884,	'r5',	'饮食',				0,		'',		'饮食'),
('A18', 'A',	'输掉游戏',	        'A',	17,		'A.17',		'',		0.0247933884,	'r5',	'输掉游戏',			0,		'',		'输掉游戏'),
('A19', 'A',	'网络谣言',	        'A',	18,		'A.18',		'',		0.0165289256,	'r5',	'网络谣言',			0,		'',		'网络谣言'),
('A20', 'A',	'体育',	            'A',	19,		'A.19',		'',		0.0165289256,	'r5',	'体育',				0,		'',		'体育'),
('A21', 'A',	'影视',	            'A',	20,		'A.20',		'',		0.0165289256,	'r5',	'影视',				0,		'',		'影视'),
('A22', 'A',	'食堂饮食',	        'A',	21,		'A.21',		'',		0.0082644628,	'r5',	'食堂饮食',			0,  	'',		'食堂饮食'),
('A23', 'A',	'自己的所作所为是否值得','A',	22,		'A.22',	    '',		0.0165289256,	'r5',	'自己的所作所为是否值得', 0,		'',		'自己的所作所为是否值得'),
('A24', 'A',	'过的生活是否是自己所追求的','A',23,		'A.23',	    '',		0.0082644628,	'r5',	'过的生活是否是自己所追求的', 0,	'',		'过的生活是否是自己所追求的'),
('A25', 'A',	'健康',	            'A',	24,		'A.24',		'',		0.0082644628,	'r5',	'健康',				0,		'',		'健康'),
('A26', 'A',	'娱乐时间',	        'A',	25,		'A.25',		'',		0.0082644628,	'r5',	'娱乐时间',			0,		'',		'娱乐时间'),
('A27', 'A',	'是否达成计划',	    'A',	26,		'A.26',		'',		0.0082644628,	'r5',	'是否达成计划',		0,		'',		'是否达成计划'),
('A28', 'A',	'做完某事的成就感',	'A',	27,		'A.27',		'',		0.0082644628,	'r5',	'做完某事的成就感',	0,		'',		'做完某事的成就感'),
('A29', 'A',	'个人形象',	        'A',	28,		'A.28',		'',		0.0082644628,	'r5',	'个人形象',			0,		'',		'个人形象'),
('A30', 'A',	'卫生环境',	        'A',	29,		'A.29',		'',		0.0082644628,	'r5',	'卫生环境',			0,		'',		'卫生环境'),
('A31', 'A',	'遭遇不幸',	        'A',	30,		'A.30',	    '',		0.0082644628,	'r5',	'遭遇不幸',			0,  	'',		'遭遇不幸'),
('A32', 'A',	'竞争队手',	        'A',	31,		'A.31',	    '',		0.0082644628,	'r5',	'竞争队手',			0,  	'',		'竞争队手'),
('A33', 'A',	'购物',	            'A',	32,		'A.32',	    '',		0.0082644628,	'r5',	'购物',				0,   	'',		'购物'),
('A34', 'A',	'谈话的态度',	   		'A',	33,		'A.33',	    '',		0.0082644628,	'r5',	'谈话的态度',			0,  	'',		'谈话的态度');

delete from ind_emotion where templId = 'B' or templId = '-B-';
INSERT INTO ind_emotion
(indId, templId, indName,   parent,		sort,	fullpath,	css,	weight,	        qtype,
 remarks,	                                                qsort,	expectings, descrpt)
VALUES
('B',   '-B-',  'Type B (8 Q)','', 	0,  	'B',    	'', 	1.0,	        '',
 'Template B',	     	                                        0,  	'',    	                        'Test 1'),

 ('B01', 'B',    '学习压力',     'B',	1,  	'B.01', 	'', 	0.1157024793,	'mr10',
 '学习压力\nTo Much study tasks, e.g. homework.',           1,      '',     '学习压力'),

('B02', 'B',	'父母/家庭关系','B',	1,	    'B.01',		'',	    0.0826446281,	's',
 '父母/家庭关系\nDoes my parents loves Mahjong more than me!',    0,		'A. I am pretty sure\nB. Not sure\nC. Nop, I''m the priorety', '父母/家庭关系'),

('B03', 'B',	'朋友/人际关系','B',	2,	    'B.02',		'',	    0.0826446281,	'r5',
 '朋友/人际关系\nThey treat me like a fool',		        0,		'',     '朋友/人际关系'),

('B04', 'B',	'考试测试',     'B',	3,  	'B.03',		'', 	0.0578512397, 	'r5',
 '考试测试\nI like AMC, how about you?',     		        0,		'',     '考试测试'),

('B05', 'B',	'恋爱/异性',   	'B',	4,		'B.04',		'',	    0.0661157025,	'r5',
 '恋爱/异性\n...',		                                    0,		'',     '恋爱/异性'),

('B06', 'B',	'追星/偶像',    'B',	5,		'B.05',		'',	    0.0578512397,	'mr5',
 '追星/偶像\nChoose Who you like most',	    	            0,		'A.Taliban\nB.ISIS\nYou name it',  '追星/偶像'),

('B07', 'B',	'学业',         'B',	6,		'B.06',		'',		0.0495867769,	'n',
 '学业\nWhat''t your last score?',				            0,		'',		'学业'),

('B08', 'B',	'天气',	        'B',	7,		'B.07',		'',		0.041322314,	'r5',
 '天气',				0,		'',		'天气')
;

delete from ind_emotion where templId = 'C' or templId = '-C-';
INSERT INTO ind_emotion
(indId, templId, indName,   parent,		sort,	fullpath,	css,	weight,	        qtype,
 remarks,	                                                qsort,	expectings, descrpt)
VALUES
('C',   '-C-',  'C: Relation', NULL,    0,  	'C',    	'', 	1.0,	        '',
 'Template C: modeified 2021-9-2',                          0,  	'',      'Templ C, 9 Q'),

 ('C01', 'C',   '学习压力',     'C',	1,  	'C.01', 	'', 	0.1157024793,	'mr10',
 '学习压力\nTo Much study tasks, e.g. homework.',           1,      '',     '学习压力'),

('C02', 'C',	'父母/家庭关系','C',	1,	    'C.01',		'',	    0.0826446281,	's',
 '父母/家庭关系\nDoes my parents loves Mahjong more than me!',    0,		'A. I am pretty sure\nB. Not sure\nC. Nop, I''m the priorety', '父母/家庭关系'),

('C03', 'C',	'朋友/人际关系','C',	2,	    'C.02',		'',	    0.0826446281,	'r5',
 '朋友/人际关系\nThey treat me like a fool',		        0,		'',     '朋友/人际关系'),

('C04', 'C',	'考试测试',     'C',	3,  	'C.03',		'', 	0.0578512397, 	'r5',
 '考试测试\nI like AMC, how about you?',     		        0,		'',     '考试测试'),

('C05', 'C',	'恋爱/异性',   	'C',	4,		'C.04',		'',	    0.0661157025,	'r5',
 '恋爱/异性\n...',		                                    0,		'',     '恋爱/异性'),

('C06', 'C',	'追星/偶像',    'C',	5,		'C.05',		'',	    0.0578512397,	'mr5',
 '追星/偶像\nChoose Who you like most',	    	            0,		'A.Taliban\nB.ISIS\nYou name it',  '追星/偶像'),

('C07', 'C',	'学业',         'C',	6,		'C.06',		'',		0.0495867769,	'n',
 '学业\nWhat''t your last score?',				            0,		'',		'学业'),


('C08', 'C',	'天气',	        'C',	7,		'C.07',		'',		0.041322314,	'r5',
 '天气',				0,		'',		'天气'),

('C09', 'A',	'健康',	            'A',	24,		'A.24',	'',	    0.0082644628,	'r5',
 '健康\nHealty conditions makes you upsetting?',	    	0,		'',	'健康 Templ C last' )
;
