# 예제 데이터 출처 및 라이선스 (DATA LICENSES)

`data/` 폴더의 예제 데이터별 출처·원저작자·라이선스·변형 여부를 정리합니다.
새 데이터를 추가할 때는 이 표에 항목을 추가하세요.

| 파일 | 내용 | 원출처 | 라이선스 | 변형 |
|------|------|--------|----------|------|
| `Galton.csv`, `Galton.txt` | 부모·자녀 키(height) 관측치 | Francis Galton(1886) 부모-자녀 키 데이터. R `mosaicData::Galton` / `HistData::GaltonFamilies`로 널리 배포 | 역사적 자료(퍼블릭 도메인). 배포 패키지는 GPL 계열 | 열 이름/형식 정리(추정) |
| `k_penguins.csv` | 남극 펭귄 3종의 부리·물갈퀴·체중·성별 | palmerpenguins (Allison Horst, Alison Hill, Kristen Gorman). 원자료: Dr. Kristen Gorman & Palmer Station Antarctica LTER | **CC0 1.0**(퍼블릭 도메인 기부) | **한글 번역**: 열 이름(종명칭/섬이름/부리_길이 …)과 값(아델리/토르거센/수컷 등)을 한국어로 변환 |

## 상세

### Galton.csv / Galton.txt

- Francis Galton이 1885~1886년 수집한 부모·자녀 키 데이터로, 회귀(regression) 개념의
  역사적 기원이 된 고전 데이터셋입니다.
- 열: `Family, Father, Mother, Gender, Height, Kids` — R `mosaicData::Galton`
  (열 `family, father, mother, sex, height, nkids`)과 동일 계열.
- 19세기 관측 자료로 저작권 보호 대상이 아닌 **퍼블릭 도메인**입니다. 이를 담은 R 패키지
  (`mosaicData`, `HistData`)는 각기 GPL 계열 라이선스로 배포됩니다.

### k_penguins.csv

- `palmerpenguins` 데이터셋의 **한글 번역본**입니다.
- 원저작자: Allison Horst, Alison Hill, Kristen Gorman. 원자료 수집: Dr. Kristen Gorman과
  Palmer Station, Antarctica LTER(Long Term Ecological Research Network).
- 원 데이터 라이선스: **CC0 1.0**(<https://creativecommons.org/publicdomain/zero/1.0/>).
- 변형: 열 이름과 범주값을 한국어로 번역(예: `species→종명칭`, `Adelie→아델리`,
  `island→섬이름`, `Torgersen→토르거센`, `sex/male→성별/수컷`).
- 원 프로젝트: <https://allisonhorst.github.io/palmerpenguins/>

## 신규 데이터 추가 시

- 위 표에 **파일명·내용·원출처·라이선스·변형 여부**를 반드시 기재하세요.
- 라이선스가 불명확하거나 재배포·상업적 이용을 금지하는 데이터는 저장소에 포함하지 마세요.
- 외부 URL에서 실시간으로 내려받는 대신, 가능하면 `data/`에 스냅샷으로 고정해
  빌드 재현성을 확보하세요(기술검토 §3.10).
