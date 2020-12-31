select
		stop_time_table.stats_hh,
        stop_time_table.site_code,
		sum(stop_time_table.tot_eprs_cnt) / sum(stop_time_table.stop_time) as avr_erps_cnt_per_min,
		case
			when sum(stop_time_table.tot_eprs_cnt) = 0 then 0
			else sum(stop_time_table.click_cnt) / sum(stop_time_table.tot_eprs_cnt)
		end as ctr,
		case
			when sum(stop_time_table.click_cnt) = 0 then 0
			else sum(stop_time_table.advrts_amt) / sum(stop_time_table.click_cnt)
		end as cpc
	from
	(SELECT
		RIGHT_TABLE.*,
		case 
			when LEFT_TABLE.stop_time is null then 60
			else LEFT_TABLE.stop_time
		end as  stop_time
	FROM
	(select STATS_DTTM, HH_NO as stats_hh, PLTFOM_TP_CODE, ADVRTS_PRDT_CODE, SITE_CODE, ITL_TP_CODE,
	MINUTE(REG_DTTM) as stop_time  
	from BILLING.TIME_CAMP_EXHS_STATS
	where dayofweek(stats_dttm) = dayofweek(20200301)
	and pltfom_tp_code = '01'
	and itl_tp_code = '01'
	and advrts_prdt_code ='01'
	and MINUTE(REG_DTTM) <> 0
	 ) as LEFT_TABLE
	RIGHT OUTER JOIN
	(select stats_dttm,dayofweek(stats_dttm) as day_of_week, stats_hh, pltfom_tp_code,advrts_prdt_code,advrts_tp_code,site_code, itl_tp_code, tot_eprs_cnt,CLICK_CNT, ADVRTS_AMT
	from BILLING.MOB_CAMP_HH_STATS
	where dayofweek(stats_dttm) = dayofweek(20200301)
	and pltfom_tp_code = '01'
	and itl_tp_code = '01'
	and advrts_prdt_code ='01' ) as RIGHT_TABLE
	on RIGHT_TABLE.STATS_DTTM = LEFT_TABLE.STATS_DTTM
	and RIGHT_TABLE.stats_hh = LEFT_TABLE.stats_hh
	and RIGHT_TABLE.pltfom_tp_code = LEFT_TABLE.pltfom_tp_code
	and RIGHT_TABLE.site_code = LEFT_TABLE.site_code
	and RIGHT_TABLE.itl_tp_code = LEFT_TABLE.itl_tp_code) as stop_time_table
	group by stats_hh,site_code