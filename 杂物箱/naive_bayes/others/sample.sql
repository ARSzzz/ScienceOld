/*
训练样本数据
列：
    ID          挂号登记ID
    CYZDDM      出院诊断代码
    XMDM        项目代码
    KSMC        科室名称
    Sl          项目数量
    JE          项目金额
*/

SELECT *
  FROM (select t1.ID, t1.CYZDDM, t3.XMDM, t1.ksmc, t3.sl, t3.je
          from wuxi.ck10_ghdj t1
          join icd10_standard_bj t2 on t1.cyzddm = t2.major_code
                                   and t1.cyzdmc = t2.disease
          join wuxi.ck10_cfmx t3 on t1.id = t3.ghdjid
         where t1.ksdm is not null
           AND T3.SL > 0
           and t1.jgmc = '无锡市人民医院')
    order by ID

/*
获取疾病与科室之间的计数信息
*/

select t1.cyzddm,  t1.ksmc, count(1) as cnt
  from wuxi.ck10_ghdj t1

  join icd10_standard_bj t3 on t1.cyzddm = t3.major_code
                           and t1.cyzdmc = t3.disease
 where t1.jgmc = '无锡市人民医院'
 group by t1.cyzddm,  t1.ksmc
