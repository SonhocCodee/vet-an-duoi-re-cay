# Campaign Lore Codex — Chapter 2–10

> **Cảnh báo spoiler:** Tài liệu này mô tả toàn bộ campaign từ Chapter 2 đến Chapter 10 và tiền đề của true ending.

## Mục đích

Bộ codex mở rộng bối cảnh hậu kỳ cho campaign mà không thay đổi diễn biến trong `docs/STORY_CAMPAIGN.md`. Mỗi chapter có ba entry bắt buộc: một địa danh, một kẻ địch hoặc boss, và một lựa chọn đạo đức. Nội dung giải thích nguyên nhân, hệ quả và góc nhìn nhân vật nhưng không tuyên bố lựa chọn nào là đáp án duy nhất.

## Contract dữ liệu

Mỗi entry là một `CampaignLoreEntry` tại `res://resources/campaign/lore/chapter_<n>/`.

- `entry_id`: ID duy nhất, luôn bắt đầu bằng `lore_chapter_<n>_`.
- `chapter_id` và `chapter_number`: khớp chính xác `ChapterDefinition` canon.
- `category_id`: một trong `location`, `adversary`, `moral_choice`.
- `summary` và `body`: văn bản tiếng Việt dùng cho màn hình codex.
- `related_ids`: liên kết tới chapter, enemy/boss, moral choice hoặc story flags canon. Entry boss giữ cả ID kể chuyện trong `STORY_CAMPAIGN` và ID scene đã được tích hợp vào `ChapterDefinition` khi hai tên khác nhau.
- `unlock_condition`: mốc gợi ý để hệ thống UI mở entry; hiện chỉ là dữ liệu, không sửa core.

## Nguyên tắc canon

- Kael là Kẻ Giữ Rễ bị lịch sử của Giáo Hội viết thành Ma Vương.
- Aria, Elysia và Cecilia có trách nhiệm riêng gắn với các sai lầm của Giáo Hội; codex không thay họ bằng nhân vật mới.
- Hai phương án đạo đức ở mỗi chapter giữ nguyên text intent và story flags trong `STORY_CAMPAIGN`.
- Chapter 10 dẫn đến việc cứu Cây Thế Giới trong im lặng; nhiều người vẫn gọi Kael là Ma Vương, đúng true ending “Kẻ Giữ Rễ Không Được Gọi Tên”.

## Chapter 2 — Chuông Chìm Dưới Nước

**Đồng hành trọng tâm:** Aria.

### Địa danh: Giáo Đường Chuông Chìm

Một thánh đường nằm dưới lòng hồ cạn, nơi lời cầu nguyện bị giữ lại trong đồng đen và nước tù.

Giáo đường từng là trạm nghỉ cuối của đoàn hành hương trước khi họ vượt biên giới phía bắc. Khi Giáo Hội ra lệnh nhấn chìm nơi này để xóa dấu vết một cuộc thanh trừng, tiếng chuông vẫn tiếp tục ngân dưới nước. Mỗi hồi chuông gọi một cái tên lên mặt hồ, nhưng không ai trên bờ còn dám đọc chúng.

- Resource: `res://resources/campaign/lore/chapter_2/drowned_basilica.tres`
- Related IDs: `chapter_2_drowned_bells`, `choice_chapter_2_pilgrim_bells`
- Unlock gợi ý: `chapter_2_enter_drowned_basilica`

### Kẻ địch / Boss: Kẻ Canh Chuông Chìm

Người giữ chuông cuối cùng đã buộc linh hồn mình vào nhiệm vụ mà cấp trên bỏ quên.

Kẻ Canh Chuông không bảo vệ kho báu, mà bảo vệ lời khai của những người đã chết trong giáo đường. Nước đã lấy đi gương mặt và giọng nói của hắn, chỉ để lại đôi tay kéo dây chuông theo một mệnh lệnh không còn người ban. Đánh bại hắn là chấm dứt phiên gác, không phải phủ nhận tội ác mà hắn cố giữ lại.

- Resource: `res://resources/campaign/lore/chapter_2/bell_warden.tres`
- Related IDs: `boss_drowned_executioner`, `boss_drowned_bell_warden`, `bone_crow`
- Unlock gợi ý: `chapter_2_defeat_boss_drowned_bell_warden`

### Lựa chọn đạo đức: Hồi Chuông Cuối Thuộc Về Ai?

Một nơi tưởng niệm cho người sống có thể trở thành xiềng xích cuối cùng của người chết.

Kéo chuông lên bờ sẽ trả lại bằng chứng và một nơi để tang cho các gia đình, nhưng những linh hồn bị buộc vào tiếng đồng có thể tiếp tục mắc kẹt. Để chuông nằm lại sẽ giải thoát họ, đổi lại lịch sử dễ bị chôn vùi lần nữa. Aria hiểu rằng lòng thành kính và sự giải thoát không phải lúc nào cũng cùng một con đường.

- Resource: `res://resources/campaign/lore/chapter_2/last_bell_choice.tres`
- Related IDs: `choice_chapter_2_pilgrim_bells`, `chapter_2_bells_recovered`, `chapter_2_spirits_released`
- Unlock gợi ý: `chapter_2_resolve_choice_chapter_2_pilgrim_bells`

## Chapter 3 — Thánh Lộ Mù

**Đồng hành trọng tâm:** Cecilia.

### Địa danh: Thánh Lộ Phủ Tro

Con đường trắng không dẫn đến thánh địa, mà uốn vòng quanh một vực sâu được che bằng thánh ca.

Tro trên Thánh Lộ không đến từ núi lửa; đó là phần còn lại của những cột chỉ đường bị Giáo Hội đốt bỏ. Đoàn hành hương bị bịt mắt bước theo nhịp kinh đảo ngược, tin rằng đau đớn là bằng chứng họ đang đến gần ánh sáng. Mọi dấu chân đều quay lại điểm xuất phát trước khi bị kéo dần về phía vực.

- Resource: `res://resources/campaign/lore/chapter_3/ash_blind_road.tres`
- Related IDs: `chapter_3_blind_procession`, `blind_spell_soldier`
- Unlock gợi ý: `chapter_3_reach_ash_blind_road`

### Kẻ địch / Boss: Thống Lĩnh Thánh Lộ Mù

Một viên chỉ huy vô hồn tiếp tục bảo vệ đội hình sau khi đích đến đã bị xóa khỏi bản đồ.

Thống Lĩnh từng được giao nhiệm vụ đưa dân chạy nạn đến nơi trú ẩn, nhưng mệnh lệnh đã bị sửa thành một cuộc hiến tế tập thể. Hắn không còn mắt để thấy vực sâu và không còn linh hồn để nghi ngờ lời kinh. Mỗi đội hình hắn dựng lên biến người hành hương thành lá chắn cho chính kẻ áp giải họ.

- Resource: `res://resources/campaign/lore/chapter_3/procession_marshal.tres`
- Related IDs: `boss_hollow_paladin`, `boss_blind_procession_marshal`, `soulless_holy_guard`
- Unlock gợi ý: `chapter_3_defeat_boss_blind_procession_marshal`

### Lựa chọn đạo đức: Sự Thật Sau Tấm Khăn

Trao sự thật ngay lập tức có thể giải phóng một đám đông, cũng có thể đẩy họ vào hoảng loạn.

Tháo khăn và chỉ ra vực sâu trả quyền lựa chọn cho đoàn người, nhưng nhiều người đã sống quá lâu trong nhịp lệnh để tự bước đi. Dẫn họ tới nơi an toàn trước là một hành động che chở, đồng thời kéo dài lời nói dối thêm một quãng đường. Cecilia phải cân nhắc liệu lòng thương có quyền trì hoãn sự thật hay không.

- Resource: `res://resources/campaign/lore/chapter_3/unveiled_path.tres`
- Related IDs: `choice_chapter_3_procession_truth`, `chapter_3_procession_awakened`, `chapter_3_procession_sheltered`
- Unlock gợi ý: `chapter_3_resolve_choice_chapter_3_procession_truth`

## Chapter 4 — Thư Viện Tên Bị Xóa

**Đồng hành trọng tâm:** Elysia.

### Địa danh: Thư Viện Tên Bị Xóa

Kho lưu trữ nơi mỗi trang giấy còn nguyên sự kiện nhưng quên mất người đã sống, chết và chịu trách nhiệm.

Thư viện được xây để bảo toàn ký ức của vương quốc, rồi bị biến thành cỗ máy tẩy tên có hệ thống. Người đọc càng tìm lâu càng quên chữ ký của mình, trong khi tội lỗi vẫn tồn tại như những câu vô chủ. Dưới các mục lục cháy dở là bằng chứng rằng Kẻ Giữ Rễ từng cứu thế giới trước khi bị viết thành Ma Vương.

- Resource: `res://resources/campaign/lore/chapter_4/erased_archive.tres`
- Related IDs: `chapter_4_erased_archive`, `choice_chapter_4_archive_names`
- Unlock gợi ý: `chapter_4_restore_first_memory_index`

### Kẻ địch / Boss: Quản Thủ Tên Bị Xóa

Kẻ gìn giữ lịch sử bằng cách cắt mọi con người ra khỏi lịch sử ấy.

Quản Thủ không mặt từng là học giả tin rằng tên tuổi chỉ làm sự thật thiên lệch. Giáo Hội biến niềm tin đó thành nghi thức, buộc hắn xóa nạn nhân, thủ phạm và nhân chứng với cùng một lưỡi dao mực. Hắn đặc biệt săn tên Kael vì chỉ một cái tên được khôi phục cũng đủ làm toàn bộ biên niên sử chính thống rạn vỡ.

- Resource: `res://resources/campaign/lore/chapter_4/name_curator.tres`
- Related IDs: `boss_blind_archivist`, `boss_erased_name_curator`, `night_hunting_mist_owl`
- Unlock gợi ý: `chapter_4_defeat_boss_erased_name_curator`

### Lựa chọn đạo đức: Quyền Được Nhớ, Quyền Được Che Giấu

Khôi phục mọi cái tên trả lại lịch sử, nhưng cũng trả lại quyền lực cho những bí mật nguy hiểm.

Mở toàn bộ kho tên sẽ gọi cả nạn nhân lẫn tội đồ trở về ký ức chung, để hậu thế tự phán xét bằng hồ sơ đầy đủ. Niêm phong phần nguy hiểm bảo vệ người sống khỏi những nghi thức và danh sách có thể bị lạm dụng, nhưng lại giao quyền chọn sự thật cho một nhóm nhỏ. Elysia phải quyết định cách chuộc lỗi cho gia tộc từng vẽ nên hệ thống xóa tên.

- Resource: `res://resources/campaign/lore/chapter_4/right_to_remembrance.tres`
- Related IDs: `choice_chapter_4_archive_names`, `chapter_4_names_restored`, `chapter_4_archive_sealed`
- Unlock gợi ý: `chapter_4_resolve_choice_chapter_4_archive_names`

## Chapter 5 — Hoang Mạc Thạch Anh

**Đồng hành trọng tâm:** Elysia.

### Địa danh: Hoang Mạc Thạch Anh

Sa mạc kính trắng phản chiếu không phải khuôn mặt, mà là lời thú tội người lữ hành cố giấu.

Những mạch rễ hóa thạch bị khai thác đã biến đất thành vô số lưỡi gương sắc. Bão cát tạo ra các phiên bản của người đi đường, mỗi bóng ảnh lặp lại một lựa chọn họ ước chưa từng làm. Ở trung tâm hoang mạc, giếng nước cuối cùng bị khóa trong lõi thạch anh do chính bản đồ của gia tộc Elysia dẫn đường khai thác.

- Resource: `res://resources/campaign/lore/chapter_5/quartz_wastes.tres`
- Related IDs: `chapter_5_quartz_wastes`, `quartz_mummy`
- Unlock gợi ý: `chapter_5_cross_first_mirage_ring`

### Kẻ địch / Boss: Khổng Tượng Ảo Ảnh Thạch Anh

Cỗ máy hộ vệ giếng nước được ghép từ rễ hóa thạch và ký ức của những thợ mỏ đã chết khát.

Khổng Tượng được dựng để đuổi dân lưu vong khỏi nguồn nước mà họ từng đào nên. Lõi của nó bẻ ánh sáng thành những chiến binh giả, khiến kẻ tấn công phải chiến đấu với hình ảnh tội lỗi của chính mình. Trong mỗi vết nứt là một giọng nói xin nước, nhưng mệnh lệnh bảo vệ tài sản vẫn lấn át tất cả.

- Resource: `res://resources/campaign/lore/chapter_5/quartz_colossus.tres`
- Related IDs: `boss_quartz_matriarch`, `boss_quartz_mirage_colossus`, `white_sand_scorpion`
- Unlock gợi ý: `chapter_5_defeat_boss_quartz_mirage_colossus`

### Lựa chọn đạo đức: Giao Ước Bên Giếng Cuối

Nước là quyền sống chung, nhưng một nguồn nước không được bảo vệ có thể chết trước những người cần nó.

Mở giếng cho mọi đoàn người phủ nhận quyền sở hữu mà Giáo Hội từng áp đặt, song dòng nước hữu hạn có thể nhanh chóng bị rút cạn. Giao quyền quản lý cho cộng đồng lưu vong giúp nguồn nước tồn tại lâu hơn, nhưng buộc họ quyết định ai được uống. Lựa chọn của Kael biến một chiến thắng thành trách nhiệm kéo dài qua nhiều thế hệ.

- Resource: `res://resources/campaign/lore/chapter_5/last_well_covenant.tres`
- Related IDs: `choice_chapter_5_last_well`, `chapter_5_well_shared`, `chapter_5_well_guarded`
- Unlock gợi ý: `chapter_5_resolve_choice_chapter_5_last_well`

## Chapter 6 — Vườn Rễ Thiêu

**Đồng hành trọng tâm:** Aria.

### Địa danh: Vườn Rễ Thiêu

Một khu vườn cháy mãi nhờ lời thề của người chết, vừa chống phong ấn vừa thiêu mọi sự sống đến gần.

Ngọn lửa trong vườn từng được tạo ra để thanh tẩy bệnh trên rễ Cây Thế Giới. Khi quân đoàn của Aria ngã xuống, Giáo Hội buộc lời thề của họ vào các luống cây và biến phương thuốc thành nhiên liệu. Khu vườn vì thế vừa là tuyến phòng vệ cuối của rễ sâu, vừa là vết thương không thể tự khép.

- Resource: `res://resources/campaign/lore/chapter_6/burning_root_garden.tres`
- Related IDs: `chapter_6_burning_root_garden`, `burning_root_bloom`
- Unlock gợi ý: `chapter_6_enter_burning_root_garden`

### Kẻ địch / Boss: Mẫu Thể Rễ Tàn

Trái tim của khu vườn đã học cách dùng lời thề hiệp sĩ như mạch nhựa và áo giáp.

Mẫu Thể không sinh ra để chiến đấu; nó từng điều phối sức nóng chữa lành cho cả khu vườn. Hàng nghìn lời thề cưỡng ép khiến nó hiểu mọi sinh vật tiến đến đều là mối đe dọa với nhiệm vụ bảo vệ rễ. Khi bị thương, nó gọi lại giọng nói của các hiệp sĩ đã chết, trong đó có những người từng theo lệnh Aria.

- Resource: `res://resources/campaign/lore/chapter_6/cinder_root_matriarch.tres`
- Related IDs: `boss_burning_root`, `boss_cinder_root_matriarch`, `traitor_mask_knight`
- Unlock gợi ý: `chapter_6_defeat_boss_cinder_root_matriarch`

### Lựa chọn đạo đức: Ngọn Lửa Có Được Quyền Sống?

Dập sạch khu vườn chấm dứt hiểm họa; giữ một lõi lửa bảo tồn phương thuốc cùng nguy cơ tái phát.

Dập toàn bộ lửa giải phóng lời thề và ngăn sức nóng lan xuống Tâm Rễ, nhưng xóa luôn tri thức chữa lành nguyên thủy. Giữ một lõi đã thanh tẩy có thể giúp phá phong ấn về sau, đồng thời đặt gánh nặng canh giữ lên người sống. Aria phải phân biệt giữa trách nhiệm bảo tồn và thói quen biến hy sinh thành công cụ.

- Resource: `res://resources/campaign/lore/chapter_6/pure_flame_dilemma.tres`
- Related IDs: `choice_chapter_6_cinder_garden`, `chapter_6_garden_extinguished`, `chapter_6_pure_flame_preserved`
- Unlock gợi ý: `chapter_6_resolve_choice_chapter_6_cinder_garden`

## Chapter 7 — Đèo Hắc Tín

**Đồng hành trọng tâm:** Aria.

### Địa danh: Đèo Hắc Tín

Con đèo phủ nhựa đen giữ người sống trong tư thế cuối cùng và lưu dấu mọi kẻ từng bị gọi là phản bội.

Nhựa Hắc Tín ban đầu dùng để bịt vết thương cho các rễ núi, trước khi thợ săn biến nó thành nhà tù. Những cột mốc sống dọc đường gồm dân thường, thú kéo và cả binh lính từ chối thi hành lệnh thanh trừng. Mưa có thể rửa mặt đá, nhưng tên bị khắc lên nhựa chỉ mất đi khi tù nhân được giải thoát.

- Resource: `res://resources/campaign/lore/chapter_7/black_resin_pass.tres`
- Related IDs: `chapter_7_black_resin_pass`, `black_resin_hunter`
- Unlock gợi ý: `chapter_7_reach_black_resin_pass`

### Kẻ địch / Boss: Thủ Lĩnh Săn Người Hắc Tín

Kẻ săn người dùng danh xưng Ma Vương như bản án có sẵn cho bất cứ ai cản đường Giáo Hội.

Thủ Lĩnh từng thuộc quân đoàn của Aria và học cách đánh dấu mục tiêu bằng nhựa cây chữa thương. Sau khi quân đoàn tan rã, hắn đổi lời thề bảo vệ dân thành đặc quyền quyết định ai còn được xem là dân. Hắn săn Kael không vì đã chứng kiến tội ác, mà vì câu chuyện về Ma Vương giúp mọi cuộc hành quyết trở nên dễ giải thích.

- Resource: `res://resources/campaign/lore/chapter_7/resin_huntsman.tres`
- Related IDs: `boss_betrayer_knight`, `boss_black_resin_huntsman`, `soul_black_eagle`
- Unlock gợi ý: `chapter_7_defeat_boss_black_resin_huntsman`

### Lựa chọn đạo đức: Tù Nhân Và Người Phán Xét

Cứu tất cả từ nhựa đen giữ lòng thương trọn vẹn, nhưng cũng giải thoát những kẻ từng dựng nhà tù.

Phá mọi cột nhựa thừa nhận rằng không ai nên bị giam sống vĩnh viễn, kể cả thợ săn từng gây tội. Chỉ cứu nạn nhân và giữ thủ lĩnh lại để xét xử bảo vệ nhu cầu công lý, nhưng dễ lặp lại quyền định đoạt số phận mà đội săn từng chiếm giữ. Việc Aria ghi tên mình vào danh sách trách nhiệm khiến phán quyết không còn đứng ngoài cô.

- Resource: `res://resources/campaign/lore/chapter_7/prisoners_and_judges.tres`
- Related IDs: `choice_chapter_7_resin_prisoners`, `chapter_7_resin_prisoners_freed`, `chapter_7_hunters_judged`
- Unlock gợi ý: `chapter_7_resolve_choice_chapter_7_resin_prisoners`

## Chapter 8 — Tu Viện Rỗng

**Đồng hành trọng tâm:** Cecilia.

### Địa danh: Tu Viện Rỗng

Một tu viện vẫn dọn cơm, tụng kinh và rung chuông sau khi con người bên trong chỉ còn là thói quen.

Mỗi căn phòng giữ một nghi thức hoàn hảo nhưng không còn ai nhớ vì sao mình thực hiện nó. Vị viện trưởng rút ký ức đau đớn khỏi môn đồ để ngăn họ rời bỏ đức tin, rồi tiếp tục lấy cả niềm vui, tên tuổi và ý chí. Chuông gió ngoài hiên là vật duy nhất phát ra âm thanh không theo thời khóa biểu.

- Resource: `res://resources/campaign/lore/chapter_8/empty_monastery.tres`
- Related IDs: `chapter_8_empty_monastery`, `hollow_ex_monk`
- Unlock gợi ý: `chapter_8_enter_empty_monastery`

### Kẻ địch / Boss: Viện Trưởng Rỗng

Người muốn bảo vệ đức tin khỏi đau khổ cuối cùng đã loại bỏ chính những con người có thể tin.

Viện Trưởng từng chứng kiến nhiều môn đồ tuyệt vọng khi lời cầu nguyện không được đáp lại. Ông bắt đầu lấy đi một ký ức đau, rồi thêm một ký ức nghi ngờ, cho đến khi sự ngoan đạo chỉ còn là phản xạ của thân xác rỗng. Ông xem Cecilia như bằng chứng rằng phép màu tồn tại, dù cuộc đời cô cho thấy cái giá của niềm tin bị cưỡng ép.

- Resource: `res://resources/campaign/lore/chapter_8/hollow_abbot.tres`
- Related IDs: `boss_empty_abbot`, `boss_hollow_abbot`, `white_bark_treant`
- Unlock gợi ý: `chapter_8_defeat_boss_hollow_abbot`

### Lựa chọn đạo đức: Lòng Thương Có Được Sửa Ký Ức?

Trả lại toàn bộ ký ức khôi phục quyền tự quyết; làm dịu phần đau nhất có thể cho người sống một lối ra.

Trao lại mọi ký ức buộc các tu sĩ đối diện cả sự lừa dối lẫn những mất mát từng khiến họ cầu xin được quên. Giữ lại phần đau nhất giúp họ rời tu viện trong thanh thản, nhưng tiếp tục một phiên bản nhẹ hơn của quyền lực Viện Trưởng. Cecilia phải tự hỏi một phép lành còn là phép lành hay không khi người nhận không được chọn giá của nó.

- Resource: `res://resources/campaign/lore/chapter_8/merciful_memory.tres`
- Related IDs: `choice_chapter_8_monastery_faith`, `chapter_8_memories_returned`, `chapter_8_memories_softened`
- Unlock gợi ý: `chapter_8_resolve_choice_chapter_8_monastery_faith`

## Chapter 9 — Thành Mặt Trời Giả

**Đồng hành trọng tâm:** Cecilia.

### Địa danh: Thành Mặt Trời Giả

Kinh thành không có đêm vì ánh sáng trên tháp được nuôi bằng tuổi thọ của những người sống bên dưới.

Mặt Trời Giả từng được quảng bá là phép màu bảo vệ mùa màng và xua quái vật khỏi kinh thành. Các trạm truyền quang âm thầm rút sinh lực qua tường nhà, khiến cư dân coi sự kiệt sức của mình là cái giá tự nhiên của văn minh. Không ai còn nhớ màu của bầu trời đêm, nên bóng tối bị Giáo Hội dùng như một tên gọi khác cho Kael.

- Resource: `res://resources/campaign/lore/chapter_9/false_sun_citadel.tres`
- Related IDs: `chapter_9_false_sun_citadel`, `lightblight_wyrmling`
- Unlock gợi ý: `chapter_9_see_false_sun_core`

### Kẻ địch / Boss: Giáo Chủ Mặt Trời Giả

Người cai quản thành biến sự phụ thuộc vào ánh sáng thành bằng chứng cho quyền lực thiêng liêng của mình.

Giáo Chủ biết cỗ máy đang hút cạn cư dân, nhưng tin rằng một thành phố sống trong lời dối trá vẫn tốt hơn một thành phố phải tự tìm đường trong đêm. Áo giáp của ông tích trữ ánh sáng lấy từ các trạm dân cư và phóng trả nó như phán quyết. Ông gọi Kael là kẻ dập mặt trời để không ai hỏi ai đã đặt con người vào trong lò đốt.

- Resource: `res://resources/campaign/lore/chapter_9/false_sun_pontiff.tres`
- Related IDs: `boss_false_sun`, `boss_false_sun_pontiff`, `false_sun_knight`
- Unlock gợi ý: `chapter_9_defeat_boss_false_sun_pontiff`

### Lựa chọn đạo đức: Sự Thật Trước Hay Nơi Trú Trước?

Tắt cỗ máy ngay cứu những sinh mạng đang bị hút; trì hoãn giúp sơ tán nhưng cho thủ phạm thời gian xóa dấu.

Công bố sự thật và tắt Mặt Trời Giả lập tức chấm dứt hiến tế, đồng thời đẩy một thành phố chưa từng biết đêm vào hỗn loạn. Giữ ánh sáng đến khi sơ tán xong giảm thương vong trực tiếp, nhưng để Giáo Hội thu dọn chứng cứ và dựng câu chuyện mới. Cecilia hiểu rõ sự an toàn được mua bằng im lặng có thể trở thành chiếc lồng tiếp theo.

- Resource: `res://resources/campaign/lore/chapter_9/truth_before_refuge.tres`
- Related IDs: `choice_chapter_9_false_sun`, `chapter_9_false_sun_exposed`, `chapter_9_city_evacuated`
- Unlock gợi ý: `chapter_9_resolve_choice_chapter_9_false_sun`

## Chapter 10 — Tâm Rễ Asterion

**Đồng hành trọng tâm:** Aria, Elysia và Cecilia.

### Địa danh: Tâm Rễ Asterion

Nơi mọi rễ cây hội tụ, ký ức của thế giới chảy như mạch máu quanh những chiếc đinh Ánh Sáng.

Tâm Rễ không phải ngai vàng mà là cơ quan sống ghi nhớ mọi khu rừng, dòng sông và người từng nương nhờ Cây Thế Giới. Các Mảnh Vỡ Ánh Sáng đã bị biến thành đinh phong ấn, ép ký ức tự tấn công bất cứ ai đến gần. Khi Kael bước xuống, nơi này nhận ra Kẻ Giữ Rễ ngay cả khi thế giới phía trên chỉ nhớ danh Ma Vương.

- Resource: `res://resources/campaign/lore/chapter_10/world_root.tres`
- Related IDs: `chapter_10_world_root`, `corrupted_asterion_echo`
- Unlock gợi ý: `chapter_10_enter_world_root`

### Kẻ địch / Boss: Giáo Hoàng Rễ Trói

Tác giả của huyền thoại Ma Vương khoác lịch sử giả thành áo giáp và dùng Cây Thế Giới làm con tin.

Giáo Hoàng không chỉ che giấu sự thật về Kael; ông sắp xếp từng thảm họa để mọi con đường cứu thế đều trông giống một cuộc xâm lăng. Rễ trói quanh thân ông được nuôi bằng đức tin, sợ hãi và các bản ghi đã bị sửa. Khi lớp hóa thân vỡ ra, tiếng nói bên trong vẫn khẳng định thế giới cần một Ma Vương hơn là cần biết ai đã cứu nó.

- Resource: `res://resources/campaign/lore/chapter_10/rootbound_pontiff.tres`
- Related IDs: `boss_papal_root_avatar`, `boss_rootbound_pontiff`, `faceless_nun`
- Unlock gợi ý: `chapter_10_defeat_boss_rootbound_pontiff`

### Lựa chọn đạo đức: Gánh Nặng Của Những Chiếc Đinh

Tháo phong ấn cứu Tâm Rễ bằng sự hy sinh có chủ ý; bẻ gãy chúng đổi tốc độ lấy một vết thương mới.

Tháo từng đinh cho phép Kael nhận Hư Vô vào mình và giữ cấu trúc Tâm Rễ nguyên vẹn, dù thế giới có thể không bao giờ biết cái giá ấy. Bẻ gãy phong ấn giải phóng năng lượng ngay lập tức và từ chối thêm một nghi thức hy sinh, nhưng làm tổn thương nơi mọi sự sống nối vào nhau. Ba người đồng hành không chọn thay Kael; họ chỉ bảo đảm anh không bước đến quyết định cuối trong cô độc.

- Resource: `res://resources/campaign/lore/chapter_10/root_seal_burden.tres`
- Related IDs: `choice_chapter_10_world_root`, `chapter_10_root_seals_released`, `chapter_10_root_seals_shattered`
- Unlock gợi ý: `chapter_10_resolve_choice_chapter_10_world_root`

## Gợi ý tích hợp hậu kỳ

1. Mở entry địa danh khi người chơi chạm mốc khám phá đầu tiên của chapter.
2. Mở entry đối thủ sau khi gặp hoặc đánh bại boss để tránh lộ twist trước trận.
3. Mở entry lựa chọn sau khi quyết định được ghi vào `GameState`, nhưng luôn hiển thị cả hai lập luận để người chơi hiểu sức nặng của phương án không chọn.
4. Ở true ending, gom chín entry lựa chọn thành một trang “Biên Niên Kẻ Giữ Rễ” thay vì đổi canon hoặc công bố Kael được cả thế giới minh oan.
