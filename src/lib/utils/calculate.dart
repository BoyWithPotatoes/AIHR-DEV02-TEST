Map od_list = {
  0.125: 10.300,
  0.250: 13.700,
  0.357: 17.100,
  0.500: 21.300,
  0.750: 26.700,
  1.000: 33.400,
  1.250: 42.200,
  1.500: 48.300,
  2.000: 60.300,
  2.500: 73.000,
  3.000: 88.900,
  3.500: 101.600,
  4.000: 114.300,
  5.000: 141.300,
  6.000: 168.300,
  8.000: 219.100,
  10.000: 273.000,
  12.000: 323.800,
  14.000: 355.600,
  16.000: 406.400,
  18.000: 457.000
};
double cal_actual_OD(double pipe_size) {
  return od_list[pipe_size] ?? 0;
} // bruh

double cal_strucural(double pipe_size) {
  double n = 1.80;
  if (pipe_size >= 20) {
    n = 3.10;
  } else if (pipe_size >= 6 && pipe_size <= 18) {
    n = 2.80;
  } else if (pipe_size == 4) {
    n = 2.30;
  } else if (pipe_size == 3) {
    n = 2.00;
  } else if (pipe_size <= 2) {
    n = 1.80;
  }
  return n;
}

double cal_design_thickness(double dp, double aod, double stress, double je) {
  return (dp * aod) / ((2 * stress * je) + (2 * dp * 0.4));
}

double cal_required_thickness(double dt, double st) {
  return dt >= st ? dt : st;
}