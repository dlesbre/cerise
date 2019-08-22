From cap_machine Require Export logrel monotone.
From iris.proofmode Require Import tactics.
From iris.program_logic Require Import weakestpre adequacy lifting.
From stdpp Require Import base. 

Section fundamental.
  Context `{memG Σ, regG Σ, STSG Σ, logrel_na_invs Σ}.
  Notation D := ((leibnizC Word) -n> iProp Σ).
  Notation R := ((leibnizC Reg) -n> iProp Σ).
  Implicit Types w : (leibnizC Word).
  Implicit Types interp : D.

  Lemma interp_cap_preserved E fs fr p l a2 a1 a0 a3 (Hne: p <> cap_lang.E):
    (((fixpoint interp1) E) (fs, fr)) (inr (p, l, a2, a1, a0)) -∗
                                      (((fixpoint interp1) E) (fs, fr)) (inr (p, l, a2, a1, a3)).
  Proof.
    repeat rewrite fixpoint_interp1_eq. simpl. iIntros "HA".
    destruct p; auto.
    - iDestruct "HA" as (g b e a ws) "(HA & HB & HC)".
      iDestruct "HA" as %?. inv H3.
      iExists g, b, e, a3, ws. iFrame; auto.
    - iDestruct "HA" as (p g b e a) "(HA & HB & HC)".
      iDestruct "HA" as %?. inv H3.
      iExists RW, g, b, e, a3. iFrame; auto.
    - iDestruct "HA" as (p g b e a) "(HA & HB & HC)".
      iDestruct "HA" as %?. inv H3.
      iExists RWL, g, b, e, a3. iFrame; auto.
    - iDestruct "HA" as (p g b e a ws) "(HA & HB & HC)".
      iDestruct "HA" as %?. inv H3.
      iExists RX, g, b, e, a3, ws. iFrame; auto.
    - elim Hne; reflexivity.
    - iDestruct "HA" as (p g b e a) "(HA & HB & HC)".
      iDestruct "HA" as %?. inv H3.
      iExists RWX, g, b, e, a3. iFrame; auto.
    - iDestruct "HA" as (p g b e a) "(HA & HB & HC)".
      iDestruct "HA" as %?. inv H3.
      iExists RWLX, g, b, e, a3. iFrame; auto.
  Qed.
  
  Lemma RX_Lea_case:
    ∀ (E0 : coPset) (r : leibnizC Reg) (a : Addr) (g : Locality) (fs : leibnizC STS_states) (fr : leibnizC STS_rels) 
      (b e : Addr) (ws : list Word) (w : Word) (dst : RegName) (r0: Z + RegName)
      (fundamental_RWX : ∀ (stsf : prodC (leibnizC STS_states) (leibnizC STS_rels)) (E : coPset) (r : leibnizC Reg) 
                           (b e : Addr) (g : Locality) (a : Addr), (na_inv logrel_nais (logN.@(b, e))
                                                                           (read_write_cond b e interp)
                                                                    → (λ (stsf0 : prodC (leibnizC STS_states) (leibnizC STS_rels)) 
                                                                         (E0 : coPset) (r0 : leibnizC Reg), 
                                                                       ((interp_expression E0 r0) stsf0) 
                                                                         (inr (RWX, g, b, e, a))) stsf E r)%I)
      (fundamental_RWLX : ∀ (stsf : prodC (leibnizC STS_states) (leibnizC STS_rels)) (E : coPset) (r : leibnizC Reg) 
                            (b e : Addr) (g : Locality) (a : Addr), (na_inv logrel_nais (logN.@(b, e))
                                                                            (read_write_local_cond b e interp)
                                                                     → (λ (stsf0 : prodC (leibnizC STS_states)
                                                                                         (leibnizC STS_rels)) 
                                                                          (E0 : coPset) (r0 : leibnizC Reg), 
                                                                        ((interp_expression E0 r0) stsf0)
                                                                          (inr (RWLX, g, b, e, a))) stsf E r)%I)
      (Hreach : ∀ ns : namespace, Some (logN.@(b, e)) = Some ns → ↑ns ⊆ E0)
      (H3 : ∀ x : RegName, (λ x0 : RegName, is_Some (r !! x0)) x)
      (i : isCorrectPC (inr (RX, g, b, e, a)))
      (Hbae : (b <= a)%a ∧ (a <= e)%a)
      (Hbe : ↑logN.@(b, e) ⊆ E0)
      (Hi : cap_lang.decode w = Lea dst r0),
      □ ▷ ▷ ((interp E0) (fs, fr)) w
        -∗ □ ▷ ([∗ list] w0 ∈ ws, ▷ ((interp E0) (fs, fr)) w0)
        -∗ □ ▷ (∀ (stsf : prodC (leibnizC STS_states) (leibnizC STS_rels)) (E1 : leibnizC coPset), [∗ list] w0 ∈ ws, ▷ 
                                                                                                                       ((interp E1) stsf) w0)
        -∗ □ (∀ r0 : RegName, ⌜r0 ≠ PC⌝ → (((fixpoint interp1) E0) (fs, fr)) (r !r! r0))
        -∗ □ na_inv logrel_nais (logN.@(b, e))
        ([[b,e]]↦ₐ[[ws]]
                ∗ (∀ (stsf : prodC (leibnizC STS_states) (leibnizC STS_rels)) (E1 : leibnizC coPset), [∗ list] w0 ∈ ws, ▷ 
                                                                                                                          ((interp E1) stsf) w0))
        -∗ □ ▷ (∀ (a0 : leibnizC Reg) (a1 : Addr) (a2 : Locality) (a3 : leibnizC STS_states) 
                  (a4 : leibnizC STS_rels) (a5 a6 : Addr) (a7 : list Word), full_map a0
                                                                                     -∗ (∀ r0 : RegName, 
                                                                                            ⌜r0 ≠ PC⌝
                                                                                            → (((fixpoint interp1) E0) (a3, a4))
                                                                                                (a0 !r! r0))
                                                                                     -∗ registers_mapsto
                                                                                     (<[PC:=
                                                                                          inr (RX, a2, a5, a6, a1)]> a0)
                                                                                     -∗ sts_full a3 a4
                                                                                     -∗ na_own logrel_nais E0
                                                                                     -∗ 
                                                                                     □ 
                                                                                     na_inv logrel_nais
                                                                                     (logN.@(a5, a6))
                                                                                     ([[a5,a6]]↦ₐ[[a7]]
                                                                                               ∗ 
                                                                                               (∀ (stsf : 
                                                                                                     prodC 
                                                                                                       (leibnizC STS_states)
                                                                                                       (leibnizC STS_rels)) 
                                                                                                  (E1 : 
                                                                                                     leibnizC coPset), [∗ list] w0 ∈ a7, ▷ 
                                                                                                                                           ((interp E1) stsf) w0))
                                                                                     -∗ 
                                                                                     □ ⌜
                                                                                     ∀ ns : namespace, 
                                                                                       Some (logN.@(a5, a6)) =
                                                                                       Some ns → 
                                                                                       ↑ns ⊆ E0⌝ -∗ 
                                                                                        ⟦ [a3, a4, E0] ⟧ₒ)
        -∗ ([∗ map] k↦y ∈ delete PC (<[PC:=inr (RX, g, b, e, a)]> r), k ↦ᵣ y)
        -∗ PC ↦ᵣ inr (RX, g, b, e, a)
        -∗ ▷ match (a + 1)%a with
             | Some ah =>
               [[ah,e]]↦ₐ[[drop (S (length (region_addrs b (get_addr_from_option_addr (a + -1)%a)))) ws]]
             | None => ⌜drop (S (length (region_addrs b (get_addr_from_option_addr (a + -1)%a)))) ws = []⌝
             end
        -∗ a ↦ₐ w
        -∗ ▷ ([[b,get_addr_from_option_addr (a + -1)%a]]↦ₐ[[take
                                                              (length
                                                                 (region_addrs b
                                                                               (get_addr_from_option_addr
                                                                                  (a + -1)%a))) ws]])
        -∗ ▷ ⌜ws =
      take (length (region_addrs b (get_addr_from_option_addr (a + -1)%a))) ws ++
           w :: drop (S (length (region_addrs b (get_addr_from_option_addr (a + -1)%a)))) ws⌝
           -∗ (▷ ([[b,e]]↦ₐ[[ws]]
                         ∗ (∀ (stsf : prodC (leibnizC STS_states) (leibnizC STS_rels)) 
                              (E1 : leibnizC coPset), [∗ list] w0 ∈ ws, ▷ ((interp E1) stsf) w0))
                 ∗ na_own logrel_nais (E0 ∖ ↑logN.@(b, e)) ={⊤}=∗ na_own logrel_nais E0)
           -∗ na_own logrel_nais (E0 ∖ ↑logN.@(b, e))
           -∗ sts_full fs fr
           -∗ WP Instr Executable
           {{ v, WP fill [SeqCtx] (of_val v)
                    {{ v0, ⌜v0 = HaltedV⌝
                           → ∃ (r0 : Reg) (fs' : STS_states) (fr' : STS_rels), 
                           full_map r0
                           ∧ registers_mapsto r0
                                              ∗ ⌜related_sts_priv fs fs' fr fr'⌝
                                              ∗ na_own logrel_nais E0 ∗ sts_full fs' fr' }} }}.
  Proof.
    intros E r a g fs fr b e ws w. intros.
    iIntros "#Hva #Hval' #Hval #Hreg #Hinv #IH".
    iIntros "Hmap HPC Hh Ha Hregionl Heqws Hcls Hown Hsts".
    rewrite delete_insert_delete.
    destruct (reg_eq_dec PC dst).
    * subst dst. destruct r0.
      { case_eq (a + z)%a; intros.
        * case_eq (a0 + 1)%a; intros.
          { iApply (wp_lea_success_z_PC with "[HPC Ha]"); eauto; iFrame.
            iNext. iIntros "(HPC & Ha)".
            iDestruct ((big_sepM_delete _ _ PC) with "[HPC Hmap]") as "Hmap /=";
              [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
            (* iDestruct (extract_from_region' _ _ a with *)
            (*                "[Heqws Hregionl Hvalidl Hh Ha]") as "Hregion"; eauto. *)
            (* { iExists _. iFrame "∗ #". } *)
            iMod ("Hcls" with "[Heqws Hregionl Hh Ha $Hown]") as "Hcls'".
            { iNext.
              iDestruct (extract_from_region' _ _ a _ (((fixpoint interp1) E) (fs, fr)) with
                             "[Heqws Hregionl Hh Ha]") as "Hregion"; eauto. 
              { iExists w. iFrame "∗ #". }
              iDestruct "Hregion" as "[$ _]". 
              iIntros (stsf' E'). rewrite -big_sepL_later. auto. 
            }
            iApply wp_pure_step_later; auto.
            iApply ("IH" with "[] [] [Hmap] [Hsts] [Hcls']"); auto. }
          { iApply (wp_lea_failPC1' with "[HPC Ha]"); eauto; iFrame.
            iNext. iIntros.  iApply wp_pure_step_later; auto.
            iNext. iApply wp_value; auto. iIntros; discriminate. }
        * iApply (wp_lea_failPC1 with "[HPC Ha]"); eauto; iFrame.
          iNext. iIntros. iApply wp_pure_step_later; auto.
          iNext. iApply wp_value; auto. iIntros; discriminate. }
      { destruct (H3 r0) as [wr0 Hsomer0].
        destruct (reg_eq_dec PC r0).
        - subst r0. iApply (wp_lea_fail6 with "[HPC Ha]"); eauto; iFrame.
          iNext. iIntros. iApply wp_pure_step_later; auto.
          iNext. iApply wp_value; auto. iIntros; discriminate.
        - iDestruct ((big_sepM_delete _ _ r0) with "Hmap") as "[Hr0 Hmap]".
          repeat rewrite lookup_delete_ne; eauto.
          destruct wr0.
          + case_eq (a + z)%a; intros.
            * case_eq (a0 + 1)%a; intros.
              { iApply (wp_lea_success_reg_PC with "[HPC Ha Hr0]"); eauto; iFrame.
                iNext. iIntros "(HPC & Ha & Hr0)".
                iDestruct ((big_sepM_delete _ _ r0) with "[Hr0 Hmap]") as "Hmap /=";
                  [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                rewrite -delete_insert_ne; auto.
                iDestruct ((big_sepM_delete _ _ PC) with "[HPC Hmap]") as "Hmap /=";
                  [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                iMod ("Hcls" with "[Heqws Hregionl Hh Ha $Hown]") as "Hcls'".
                { iNext.
                  iDestruct (extract_from_region' _ _ a _ (((fixpoint interp1) E) (fs, fr)) with
                                 "[Heqws Hregionl Hh Ha]") as "Hregion"; eauto. 
                  { iExists w. iFrame "∗ #". }
                  iDestruct "Hregion" as "[$ _]". 
                  iIntros (stsf' E'). rewrite -big_sepL_later. auto. 
                }
                iApply wp_pure_step_later; auto. rewrite (insert_id _ r0); auto.
                iApply ("IH" with "[] [] [Hmap] [Hsts] [Hcls']"); auto. }
              { iApply (wp_lea_failPCreg1' with "[HPC Ha Hr0]"); eauto; iFrame.
                iNext. iIntros.  iApply wp_pure_step_later; auto.
                iNext. iApply wp_value; auto. iIntros; discriminate. }
            * iApply (wp_lea_failPCreg1 with "[HPC Ha Hr0]"); eauto; iFrame.
              iNext. iIntros. iApply wp_pure_step_later; auto.
              iNext. iApply wp_value; auto. iIntros; discriminate.
          + iApply (wp_lea_failPC5 with "[HPC Ha Hr0]"); eauto; iFrame.
            iNext. iIntros. iApply wp_pure_step_later; auto.
            iNext. iApply wp_value; auto. iIntros; discriminate. }
    * destruct (H3 dst) as [wdst Hsomedst].
      iDestruct ((big_sepM_delete _ _ dst) with "Hmap") as "[Hdst Hmap]"; eauto.
      rewrite lookup_delete_ne; eauto.
      destruct wdst.
      { iApply (wp_lea_fail2 with "[HPC Ha Hdst]"); eauto; iFrame.
        iNext. iIntros. iApply wp_pure_step_later; auto.
        iNext. iApply wp_value; auto. iIntros; discriminate. }
      { destruct c, p, p, p.
        destruct (perm_eq_dec p cap_lang.E).
        - subst p. destruct r0.
          + iApply (wp_lea_fail1 with "[HPC Ha Hdst]"); eauto; iFrame.
            iNext. iIntros. iApply wp_pure_step_later; auto.
            iNext. iApply wp_value; auto. iIntros; discriminate.
          + iApply (wp_lea_fail3 with "[HPC Ha Hdst]"); eauto; iFrame.
            iNext. iIntros. iApply wp_pure_step_later; auto.
            iNext. iApply wp_value; auto. iIntros; discriminate.
        - destruct r0.
          + case_eq (a0 + z)%a; intros.
            * case_eq (a + 1)%a; intros.
              { iApply (wp_lea_success_z with "[HPC Ha Hdst]"); eauto; iFrame.
                iNext. iIntros "(HPC & Ha & Hdst)".
                iDestruct ((big_sepM_delete _ _ dst) with "[Hdst Hmap]") as "Hmap /=";
                  [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                repeat rewrite -delete_insert_ne; auto.
                iDestruct ((big_sepM_delete _ _ PC) with "[HPC Hmap]") as "Hmap /=";
                  [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                iMod ("Hcls" with "[Heqws Hregionl Hh Ha $Hown]") as "Hcls'".
                { iNext.
                  iDestruct (extract_from_region' _ _ a _ (((fixpoint interp1) E) (fs, fr)) with
                                 "[Heqws Hregionl Hh Ha]") as "Hregion"; eauto. 
                  { iExists _. rewrite H5; iFrame "∗ #". }
                  iDestruct "Hregion" as "[$ _]". 
                  iIntros (stsf' E'). rewrite -big_sepL_later. auto. 
                }
                iApply wp_pure_step_later; auto.
                iAssert ((interp_registers _ _ (<[dst:=inr (p, l, a2, a1, a3)]> r)))%I
                  as "[Hfull' Hreg']".
                { iSplitL.
                  - iIntros (r2). destruct (reg_eq_dec dst r2); [subst r2; rewrite lookup_insert; eauto| rewrite lookup_insert_ne; auto].
                  - iIntros (r2 Hnepc). destruct (reg_eq_dec dst r2).
                    + subst r2. rewrite /RegLocate lookup_insert.
                      iDestruct ("Hreg" $! dst Hnepc) as "HA". rewrite Hsomedst.
                      simpl. iApply (interp_cap_preserved with "HA"); auto.
                    + rewrite /RegLocate lookup_insert_ne; auto.
                      iApply "Hreg"; auto. }
                iApply ("IH" with "[Hfull'] [Hreg'] [Hmap] [Hsts] [Hcls']"); auto. }
              { iApply (wp_lea_fail1' with "[HPC Ha Hdst]"); eauto; iFrame.
                iNext. iIntros. iApply wp_pure_step_later; auto.
                iNext. iApply wp_value; auto. iIntros; discriminate. }
            * iApply (wp_lea_fail1 with "[HPC Ha Hdst]"); eauto; iFrame.
              iNext. iIntros. iApply wp_pure_step_later; auto.
              iNext. iApply wp_value; auto. iIntros; discriminate.
          + destruct (H3 r0) as [wr0 Hsomer0].
            destruct (reg_eq_dec PC r0).
            * subst r0. iApply (wp_lea_fail6 with "[HPC Ha]"); eauto; iFrame.
              iNext. iIntros. iApply wp_pure_step_later; auto.
              iNext. iApply wp_value; auto. iIntros; discriminate.
            * destruct (reg_eq_dec dst r0).
              { subst r0. iApply (wp_lea_fail7 with "[HPC Ha Hdst]"); eauto; iFrame.
                iNext. iIntros. iApply wp_pure_step_later; auto.
                iNext. iApply wp_value; auto. iIntros; discriminate. }
              { iDestruct ((big_sepM_delete _ _ r0) with "Hmap") as "[Hr0 Hmap]".
                repeat rewrite lookup_delete_ne; eauto.
                destruct wr0.
                - case_eq (a0 + z)%a; intros.
                  * case_eq (a + 1)%a; intros.
                    { revert H4; intro H4.
                      iApply (wp_lea_success_reg with "[HPC Ha Hdst Hr0]"); eauto; iFrame.
                      iNext. iIntros "(HPC & Ha & Hr0 & Hdst)".
                      iDestruct ((big_sepM_delete _ _ r0) with "[Hr0 Hmap]") as "Hmap /=";
                        [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                      repeat rewrite -delete_insert_ne; auto.
                      iDestruct ((big_sepM_delete _ _ dst) with "[Hdst Hmap]") as "Hmap /=";
                        [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                      repeat rewrite -delete_insert_ne; auto.
                      iDestruct ((big_sepM_delete _ _ PC) with "[HPC Hmap]") as "Hmap /=";
                        [apply lookup_insert|rewrite delete_insert_delete;iFrame|]. simpl.
                      iMod ("Hcls" with "[Heqws Hregionl Hh Ha $Hown]") as "Hcls'".
                      { iNext.
                        iDestruct (extract_from_region' _ _ a _ (((fixpoint interp1) E) (fs, fr)) with
                                       "[Heqws Hregionl Hh Ha]") as "Hregion"; eauto. 
                        { iExists _. rewrite H5; iFrame "∗ #". }
                        iDestruct "Hregion" as "[$ _]". 
                        iIntros (stsf' E'). rewrite -big_sepL_later. auto. 
                      }
                      iApply wp_pure_step_later; auto.
                      iAssert ((interp_registers _ _ (<[dst:=inr (p, l, a2, a1, a3)]> (<[r0:=inl z]> r))))%I
                        as "[Hfull' Hreg']".
                      { iSplitL.
                        - iIntros (r2). destruct (reg_eq_dec dst r2); [subst r2; rewrite lookup_insert; eauto| rewrite lookup_insert_ne; auto].
                          destruct (reg_eq_dec r0 r2); [subst r2; rewrite lookup_insert; eauto| rewrite lookup_insert_ne; auto].
                        - iIntros (r2 Hnepc). destruct (reg_eq_dec dst r2).
                          + subst r2. rewrite /RegLocate lookup_insert.
                            iDestruct ("Hreg" $! dst Hnepc) as "HA". rewrite Hsomedst.
                            simpl. iApply (interp_cap_preserved with "HA"); auto.
                          + rewrite /RegLocate lookup_insert_ne; auto.
                            destruct (reg_eq_dec r0 r2).
                            * subst r2; rewrite lookup_insert. simpl.
                              repeat rewrite fixpoint_interp1_eq. simpl. eauto.
                            * rewrite lookup_insert_ne; auto.
                              iApply "Hreg"; auto. }
                      iApply ("IH" with "[Hfull'] [Hreg'] [Hmap] [Hsts] [Hcls']"); auto. }
                    { iApply (wp_lea_fail4' with "[HPC Ha Hdst Hr0]"); eauto; iFrame.
                      iNext. iIntros. iApply wp_pure_step_later; auto.
                      iNext. iApply wp_value; auto. iIntros; discriminate. }
                  * iApply (wp_lea_fail4 with "[HPC Ha Hdst Hr0]"); eauto; iFrame.
                    iNext. iIntros. iApply wp_pure_step_later; auto.
                    iNext. iApply wp_value; auto. iIntros; discriminate.
                - iApply (wp_lea_fail5 with "[HPC Ha Hdst Hr0]"); eauto; iFrame.
                  iNext. iIntros. iApply wp_pure_step_later; auto.
                  iNext. iApply wp_value; auto. iIntros; discriminate. } }
  Qed.

  End fundamental.