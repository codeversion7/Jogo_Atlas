extends Resource
@export_range(1,120) var first_reach := 40.0
@export_range(1,120) var second_reach := 52.0
@export_range(0.1,1.5) var half_angle := 0.85
func radius(level: int) -> float:
	return 0.0 if level<=0 else clampf(first_reach if level==1 else maxf(first_reach,second_reach),1,120)
