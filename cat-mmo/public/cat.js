/**
 * Custom Cat Animation System
 * Handles animation states for the cat model with proper idle, walk, run, and attack states
 */

class CatAnimator {
  constructor(catModel, mixer, catActions) {
    this.catModel = catModel;
    this.mixer = mixer;
    this.catActions = catActions;
    this.currentAction = 'idle';
    this.state = {
      bobPhase: 0,
      attackTime: 0,
      attackActive: false,
      lastAction: 'idle'
    };
  }

  /**
   * Update the cat animation based on movement state
   * @param {number} delta - Time delta since last frame (ms)
   * @param {boolean} isMoving - Whether the cat is moving
   * @param {boolean} isRunning - Whether the cat is running
   * @param {boolean} isGrounded - Whether the cat is on the ground
   * @param {Object} attackPaw - Reference to attack paw mesh if available
   * @param {Object} attackPawOriginalRotation - Original rotation of attack paw
   */
  update(delta, isMoving, isRunning, isGrounded, attackPaw, attackPawOriginalRotation) {
    // If no model, skip animation
    if (!this.catModel) return;

    // Handle attack animation first (takes priority)
    if (this.state.attackActive) {
      this.updateAttackAnimation(delta, attackPaw, attackPawOriginalRotation);
      return;
    }

    // If we have an animation mixer (model has animations), use them
    if (this.mixer && this.catActions) {
      this.updateWithAnimationClips(isMoving, isRunning);
    } else {
      // Fallback to manual animation
      this.updateManualAnimation(delta, isMoving, isRunning, isGrounded, attackPaw, attackPawOriginalRotation);
    }
  }

  /**
   * Update animation using Three.js animation mixer and clips
   */
  updateWithAnimationClips(isMoving, isRunning) {
    let targetAction = 'idle';

    if (isMoving) {
      targetAction = isRunning ? 'run' : 'walk';
    }

    // Only transition if action changed
    if (this.currentAction !== targetAction) {
      const fromAction = this.catActions[this.currentAction];
      const toAction = this.catActions[targetAction];

      if (fromAction && toAction) {
        fromAction.fadeOut(0.3);
        toAction.reset();
        toAction.fadeIn(0.3);
        toAction.play();
        this.currentAction = targetAction;
      }
    }
  }

  /**
   * Manual animation fallback (for models without animation clips)
   * Creates smooth bobbing and swaying motion
   */
  updateManualAnimation(delta, isMoving, isRunning, isGrounded, attackPaw, attackPawOriginalRotation) {
    // Only animate if actually moving - key fix to prevent constant running animation
    if (isMoving) {
      const speed = isRunning ? 0.015 : 0.008; // Faster bob when running
      this.state.bobPhase += delta * speed;

      const bobAmplitude = isRunning ? 0.22 : 0.15;
      const bob = Math.sin(this.state.bobPhase) * bobAmplitude;
      const sway = Math.sin(this.state.bobPhase * 2.2) * (isRunning ? 0.1 : 0.06);

      this.catModel.position.y = bob + (isGrounded ? 0 : 0.16);
      this.catModel.rotation.z = sway;
      this.currentAction = isRunning ? 'run' : 'walk';
    } else {
      // STATIONARY STATE - minimal/no animation
      // Just a very subtle idle bob
      const idleSpeed = 0.002;
      this.state.bobPhase += delta * idleSpeed;

      const subtleBob = Math.sin(this.state.bobPhase) * 0.02; // Very subtle
      const subtleSway = Math.sin(this.state.bobPhase * 0.5) * 0.01; // Almost imperceptible

      this.catModel.position.y = subtleBob + (isGrounded ? 0 : 0.16);
      this.catModel.rotation.z = subtleSway;
      this.currentAction = 'idle';
    }

    // Handle pitch rotation based on ground state
    if (!isGrounded) {
      this.catModel.rotation.x = -0.25;
    } else {
      this.catModel.rotation.x = 0;
    }
  }

  /**
   * Update attack animation
   */
  updateAttackAnimation(delta, attackPaw, attackPawOriginalRotation) {
    const attackAnimationDuration = 1000;

    this.state.attackTime += delta;
    const progress = Math.min(1, this.state.attackTime / attackAnimationDuration);
    const swing = Math.sin(progress * Math.PI) * 1.0;

    if (attackPaw && attackPawOriginalRotation) {
      attackPaw.rotation.x = attackPawOriginalRotation.x - swing;
      attackPaw.rotation.y = attackPawOriginalRotation.y + 0.15;
    } else {
      this.catModel.rotation.x = -swing * 0.3;
      this.catModel.rotation.z = 0;
    }

    if (progress >= 1) {
      this.state.attackActive = false;
      this.state.attackTime = 0;
      if (attackPaw && attackPawOriginalRotation) {
        attackPaw.rotation.copy(attackPawOriginalRotation);
      } else {
        this.catModel.rotation.x = 0;
      }
    }
  }

  /**
   * Start an attack animation
   */
  startAttack() {
    this.state.attackActive = true;
    this.state.attackTime = 0;
  }

  /**
   * Get the current animation state
   */
  getCurrentAction() {
    return this.currentAction;
  }

  /**
   * Check if currently attacking
   */
  isAttacking() {
    return this.state.attackActive;
  }

  /**
   * Transition to a specific animation (for manual control)
   */
  transitionTo(actionName) {
    if (this.mixer && this.catActions && this.catActions[actionName]) {
      const fromAction = this.catActions[this.currentAction];
      const toAction = this.catActions[actionName];

      if (fromAction && toAction) {
        fromAction.fadeOut(0.2);
        toAction.reset();
        toAction.fadeIn(0.2);
        toAction.play();
        this.currentAction = actionName;
      }
    }
  }
}

// Export for use in main script
if (typeof module !== 'undefined' && module.exports) {
  module.exports = CatAnimator;
}
