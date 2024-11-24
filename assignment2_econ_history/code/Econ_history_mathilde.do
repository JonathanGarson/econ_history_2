clear
import excel "C:\Users\Dell\Downloads\JSTdatasetR6.xlsx", firstrow clear
describe
gen real_credit = tloans / cpi
sort country year
gen log_real_credit = log(real_credit)
gen log_change_real_credit = log_real_credit - log_real_credit[_n-1] if country == country[_n-1]

bysort country (year): gen lag_1 = log_change_real_credit[_n-1]
bysort country (year): gen lag_2 = log_change_real_credit[_n-2]
bysort country (year): gen lag_3 = log_change_real_credit[_n-3]
bysort country (year): gen lag_4 = log_change_real_credit[_n-4]
bysort country (year): gen lag_5 = log_change_real_credit[_n-5]

gen missing_lags = missing(lag_1, lag_2, lag_3, lag_4, lag_5)
drop if missing_lags

encode country, gen(country_num)

logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num
estimates store full_model
logit crisisJST i.country_num
estimates store restricted_model
lrtest full_model restricted_model

logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num
test lag_1 lag_2 lag_3 lag_4 lag_5

*QUESTION A.2
gen post_1984 = year > 1984
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num if post_1984 == 0
predict in_sample_pred if post_1984 == 0

predict out_of_sample_pred if post_1984 == 1

roctab crisisJST in_sample_pred if post_1984 == 0, graph
roctab crisisJST out_of_sample_pred if post_1984 == 1, graph

*compare the baseline model to a logit model with money
gen missing_lags_2 = missing(narrowm)
drop if missing_lags_2
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num
estimates store baseline_model
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 narrowm i.country_num
estimates store money_model
*LR test
lrtest money_model baseline_model

*Wald Test
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 narrowm i.country_num
test narrowm

*ROC for baseline
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num
predict baseline_model
roctab crisisJST baseline_model,graph

*ROC for money model 
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 narrowm i.country_num
predict money_model
roctab crisisJST money_model,graph

*compare the baseline model to a logit model with public debt
gen missing_lags_3 = missing(debtgdp)
drop if missing_lags_3

logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num
estimates store baseline_model_2
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 debtgdp i.country_num
estimates store debt_model
*LR test
lrtest debt_model baseline_model_2

*Wald
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 debtgdp i.country_num
test debtgdp

*ROC for baseline 2
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 i.country_num
predict baseline_model_2
roctab crisisJST baseline_model_2, graph

*ROC for money model 
logit crisisJST lag_1 lag_2 lag_3 lag_4 lag_5 debtgdp i.country_num
predict debt_model
roctab crisisJST debt_model, graph
