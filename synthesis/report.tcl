# This script generates a coverage report from a coverage database
#

vcover report -html -htmldir htmlcoverage -verbose -threshL 50 -threshH 90 codecoverage.ucdb 
quit
