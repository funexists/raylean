
/-- Execute a computation in a modified environment --/
def ReaderT.local {ρ : Type u} (f : ρ → ρ) (r : ReaderT ρ m α) : ReaderT ρ m α := r.run ∘ f
