extends AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "_on_animation_finished") # Conectando sinal via codigo (sinal, node que possui o sinal, nome da funcao)
	frame = 0
	play("Animate")

func _on_animation_finished():
	queue_free()
