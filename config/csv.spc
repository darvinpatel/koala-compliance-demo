# Steampipe csv plugin connection for the synthetic Koala Freight estate.
# scripts/run_benchmarks.sh copies this to ~/.steampipe/config/csv.spc, replacing __REPO__ with the
# absolute path of this folder. To set it by hand, edit the path below to wherever you unzipped the bundle.
connection "csv" {
  plugin = "csv"
  paths  = ["__REPO__/data/*.csv"]
}
