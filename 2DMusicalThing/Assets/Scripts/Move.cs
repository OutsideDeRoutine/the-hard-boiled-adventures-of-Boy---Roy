using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class Move : MonoBehaviour {

    public string verticalInput = "Vertical";
    public string horizontalInput = "Horizontal";
    public float Mass;
    public float Speed = 0.01f;
    private CharacterController _controller;
    private Animator _animator;
    private SpriteRenderer _renderer;

    // Use this for initialization
    void Start () {
        _controller = GetComponent<CharacterController>();
        _animator = GetComponent<Animator>();
        _renderer = GetComponent<SpriteRenderer>();
    }

    private float v;
    private float h;
    // Update is called once per frame
    void FixedUpdate () {
        if (!customMove)
        {
            v = Input.GetAxis(verticalInput);
            h = Input.GetAxis(horizontalInput);
        }
        customMove = false;

        //ANIMATION
        if (v != 0 || h != 0)
        {
            if (!_animator.GetBool("walking"))
                _animator.SetBool("walking", true);
            if (v == 0)
            {
                _animator.SetInteger("looking", 0);
                if (h < 0)
                {
                    _renderer.flipX = false;
                }
                else
                {
                    _renderer.flipX = true;
                }
            }
            else if (h == 0)
            {
                _animator.SetInteger("looking", v > 0 ? -1 : 1);
            }
            else
            {
                if(Mathf.Abs(v) < Mathf.Abs(h))
                {
                    _animator.SetInteger("looking", 0);
                    if (h < 0)
                    {
                        _renderer.flipX = false;
                    }
                    else
                    {
                        _renderer.flipX = true;
                    }
                }
                else
                {
                    _animator.SetInteger("looking", v > 0 ? -1 : 1);
                }
            }
            
        }
        else if (_animator.GetBool("walking"))
        {
            _animator.SetBool("walking", false);
        }

        //MOVE
        float gravity = -9.81f * Time.deltaTime * Mass;
        if (_controller.isGrounded)
        {
            gravity = 0;
        }
        Vector3 move = this.transform.forward * v + this.transform.right * h;
        move = move.normalized * Time.deltaTime * Speed + Vector3.up * gravity;
        _controller.Move(move);

        
    }

    private bool customMove;
    public void MakeMyMove(float h, float v)
    {
        this.h = h;
        this.v = v;
        customMove = true;
    }
}
