# 기여 가이드 (CONTRIBUTING)

빛스탯2에 기여해 주셔서 감사합니다. 이 문서는 콘텐츠·앱을 추가/수정할 때 지켜야 할
규칙과 PR 체크리스트를 정리합니다. 저장소 전반의 작업 가이드는 [CLAUDE.md](../CLAUDE.md),
개선 로드맵은 [PLAN.md](PLAN.md)를 참고하세요.

## 0. 개발 환경

- **Quarto 1.10+**, **R 4.x** 필요.
- shinylive·webr 필터는 `_extensions/`에 번들되어 있어 별도 설치가 필요 없습니다.
- 로컬 확인:
  ```bash
  quarto preview     # http://localhost:7771
  quarto render 경로/index.qmd   # 단일 파일만 렌더
  ```

## 1. 정본(Single Source of Truth) 규칙 — 가장 중요

- **실제 배포되는 것은 `index.qmd` 내 인라인 `{shinylive-r}` 블록이며, 이것이 유일 정본입니다.**
- 과거 각 모듈에 있던 `shiny/app.R`는 빌드가 참조하지 않는 stale 사본(drift 8/23)이어서
  **2026-07-05에 전부 삭제**했습니다. `shiny/` 폴더를 새로 만들지 마세요.
- **앱을 고칠 때는 `index.qmd`의 인라인 블록을 수정하세요.**
- 근거: [tech_document/2026-07-05_기술검토.md](tech_document/2026-07-05_기술검토.md) §3.1

## 2. 한글 폰트

한글 라벨을 그리는 **모든 Shiny 앱과 그림을 그리는 webr 코드셀**은 표준 스니펫을 포함합니다.

```r
library(showtext)
showtext_auto()
```

- 이 패턴은 shinylive/webR(WASM)에서 한글 렌더가 확인되었습니다(예: `05_infer/clt`).
- **금지**: `family = "Tahoma"` 등 Windows 전용·WASM 부재 폰트(한글 미표시, □□□).
- `base_family = "Nanum Gothic"`처럼 특정 폰트를 지정하려면 `font_add_google("Nanum Gothic")`로
  **등록**한 뒤 사용하세요. 등록 없이 이름만 참조하면 폴백됩니다.
- 근거: 기술검토 §3.2

## 3. 신규 모듈 추가

1. `pages/NN_topic/module_name/index.qmd` 생성.
2. YAML front matter 필수값:
   ```yaml
   ---
   title: "모듈 제목"
   author: "작성자"
   date: today
   image: thumbnail.png
   image-alt: "썸네일 대체 텍스트"
   categories: [주제, 태그]
   ---
   ```
3. 인라인 `{shinylive-r}` 블록으로 앱 작성(위 폰트 스니펫 포함).
4. `thumbnail.png` 추가(리스팅 그리드용).
5. 랜덤 예제가 정적으로 렌더된다면 `set.seed()`를 넣어 재현성 확보.

## 4. 데이터

- 외부 URL 데이터는 가능하면 `data/`에 스냅샷으로 두고 참조합니다(빌드 재현성).
- 새 데이터 추가 시 [DATA_LICENSES.md](DATA_LICENSES.md)에 출처·원저작자·라이선스·변형 여부를 기재합니다.

## 5. PR 체크리스트

제출 전 아래를 확인하세요.

- [ ] 앱 수정은 **`index.qmd` 인라인 블록**에 반영했다(정본 위치 준수).
- [ ] 한글 라벨 앱/코드셀에 `library(showtext); showtext_auto()` 포함, `Tahoma` 등 부재 폰트 미사용.
- [ ] 신규 모듈은 YAML 필수값(`title`/`author`/`date`/`image`/`categories`)과 `thumbnail.png` 구비.
- [ ] 썸네일/그림에 `image-alt`/`fig-alt` 대체 텍스트 제공(접근성).
- [ ] 정적 랜덤 예제에 `set.seed()` 적용.
- [ ] 새 데이터는 `DATA_LICENSES.md`에 출처·라이선스 기재.
- [ ] `quarto render 경로/index.qmd`가 오류 없이 성공.
- [ ] (권장) 배포 미리보기에서 한글 라벨이 정상 렌더되는지 확인.

## 6. 라이선스 동의

기여하신 내용은 저장소 라이선스 정책에 따라 배포됩니다.

- 코드: [GPL-3.0](../LICENSE)
- 콘텐츠: [CC BY-NC-SA 4.0](LICENSE-content.md)
